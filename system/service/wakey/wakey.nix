{ pkgs, ... }:

# Wakey problem bank: HTTP API (Swagger UI at /docs, /health for the status page), MCP and TUI tools.
# After the first switch, create an API key for the phone (printed once):
#   wakey-admin key create --name phone --scopes read,progress --subject beau
# Tools (run as the service user through sudo): wakey-admin (key, ingest, seed), wakey-tui, wakey-mcp.
let
  wakey = pkgs.buildGoModule {
    pname = "wakey";
    version = "1.0.0";

    src = pkgs.fetchgit {
      url = "https://git.bjvanbemmel.nl/bjvanbemmel/wakey";
      rev = "08d8056c7d504997176c4d8233a51cec16b155d5";
      hash = "sha256-BO7PMGTp6ldpInyOZHWBGmVqVDc9J+oVohOPf9GSqWw=";
    };

    # The Go module lives in backend/. cgo is on by default (go-sqlite3); migrations, the OpenAPI spec and
    # Swagger UI are embedded in the binaries.
    modRoot = "backend";
    subPackages = [ "cmd/wakeyd" "cmd/wakey-mcp" "cmd/wakey-tui" ];
    vendorHash = "sha256-ebyw0b5pBy2CE4mfGPHgXS5hJVz+PvJB2lgsuhi2dAY=";
  };

  listen = "127.0.0.1:3003";
  stateDir = "/var/lib/wakey";

  # Admin tools share the daemon's database, so they run as the service user.
  tool = name: bin: pkgs.writeShellScriptBin name ''
    export STATE_DIRECTORY=${stateDir}
    if [ "$(id -un)" = wakey ]; then exec ${wakey}/bin/${bin} "$@"; fi
    exec /run/wrappers/bin/sudo -u wakey --preserve-env=STATE_DIRECTORY ${wakey}/bin/${bin} "$@"
  '';

  serviceConfig = {
    User = "wakey";
    Group = "wakey";
    StateDirectory = "wakey";
    StateDirectoryMode = "0750";
    NoNewPrivileges = true;
    PrivateTmp = true;
    PrivateDevices = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
    RestrictNamespaces = true;
    LockPersonality = true;
    SystemCallArchitectures = "native";
  };
in
{
  users.users.wakey = {
    isSystemUser = true;
    group = "wakey";
  };
  users.groups.wakey = { };

  systemd.services.wakey = {
    description = "Wakey problem bank";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    # Configuration is environment-only. Problems and quotes are readable without a key; progress and
    # authoring need an API key.
    environment = {
      LISTEN = listen;
      PUBLIC_READ = "true";
      DOCS = "true";
    };

    serviceConfig = serviceConfig // {
      # Loads the 64 built-in starter problems on every start (idempotent: existing ones are skipped).
      ExecStartPre = "${wakey}/bin/wakeyd seed";
      ExecStart = "${wakey}/bin/wakeyd";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # Weekly quote refresh from Wikiquote.
  systemd.services.wakey-ingest = {
    description = "Refresh Wakey quotes from Wikiquote";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = serviceConfig // {
      Type = "oneshot";
      ExecStart = "${wakey}/bin/wakeyd ingest";
    };
  };
  systemd.timers.wakey-ingest = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  # Lets beauv start the MCP server as the service user without a password prompt, so Claude can run it over ssh
  # (ssh beauv@bjvanbemmel.nl wakey-mcp). Only this one binary, only as the wakey user.
  security.sudo.extraRules = [
    {
      users = [ "beauv" ];
      runAs = "wakey";
      commands = [
        {
          command = "${wakey}/bin/wakey-mcp";
          options = [ "NOPASSWD" "SETENV" ];
        }
      ];
    }
  ];

  environment.systemPackages = [
    (tool "wakey-admin" "wakeyd")
    (tool "wakey-tui" "wakey-tui")
    (tool "wakey-mcp" "wakey-mcp")
  ];

  services.nginx.virtualHosts."wakey.bjvanbemmel.nl" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3003";
      # Sets X-Real-IP / X-Forwarded-For: wakeyd rate limits POST /v1/register per caller address.
      recommendedProxySettings = true;
    };
    # MCP over streamable HTTP: no buffering of the event stream, and no access log because the key can sit in the path.
    locations."/mcp" = {
      proxyPass = "http://127.0.0.1:3003";
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_read_timeout 1h;
        access_log off;
      '';
    };
  };
}
