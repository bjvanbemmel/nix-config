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
      rev = "20c8eae60c17e9ff7b09bae703ff03268dccfa71";
      hash = "sha256-mKDJfNrApqrgQSYvESLeCfP+OtpzYj/T1XcB3RZf24I=";
    };

    # The Go module lives in backend/. cgo is on by default (go-sqlite3); migrations, the OpenAPI spec and
    # Swagger UI are embedded in the binaries.
    modRoot = "backend";
    subPackages = [ "cmd/wakeyd" "cmd/wakey-mcp" "cmd/wakey-tui" ];
    vendorHash = "sha256-ebyw0b5pBy2CE4mfGPHgXS5hJVz+PvJB2lgsuhi2dAY=";

    # This commit's go.mod demands go 1.26.8; nixpkgs 26.05 may carry an older 1.26.x. Drop once a later
    # commit (go 1.26.0) is pinned above.
    postPatch = ''
      sed -i 's/^go 1\.26\.8$/go 1.26.0/' backend/go.mod
    '';
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
    };
  };
}
