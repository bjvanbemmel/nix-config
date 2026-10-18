{ pkgs, ... }:

# Housey: Dutch house-search backend. Scrapes listing sites on a timer, watches the Funda alert mailbox over IMAP IDLE,
# matches against the app's preferences and pushes new matches to the phone over server-sent events (GET /events).
# Secrets live out of band in /etc/housey.env (root, mode 0600):
#   IMAP_HOST=...
#   IMAP_PORT=993
#   IMAP_USER=...
#   IMAP_PASSWORD=...
#   MAIL_ALERT_ADDRESS=funda@bjvanbemmel.nl
let
  housey = pkgs.buildGoModule {
    pname = "housey";
    version = "0.1.0";

    src = pkgs.fetchgit {
      url = "https://git.bjvanbemmel.nl/bjvanbemmel/Housey";
      rev = "f0418f08c3c9a2e73b221c2fce41ea871751c3c5";
      hash = "sha256-bVntzTCq6b5MF8e4lfrCSvDITjx18haxHx8vSEf+/Cc=";
    };

    # The Go module lives in backend/. cgo is on by default (go-sqlite3); migrations are embedded in the binary.
    modRoot = "backend";
    vendorHash = "sha256-JYWR7Hm5nUFu6VIA+b2U9ge8D6bqFdxVy316BjPJUEI=";
    doCheck = false; # the tests drive a real Chromium over the network
  };
in
{
  systemd.services.housey = {
    description = "Housey house-search backend";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    environment = {
      PORT = "3004";
      SCRAPE_MINUTES = "5";
      DB = "/var/lib/housey/housey.db";
      CHROME = "${pkgs.chromium}/bin/chromium";
      HOME = "/var/lib/housey"; # Chromium profile
    };

    serviceConfig = {
      ExecStart = "${housey}/bin/backend";
      EnvironmentFile = "-/etc/housey.env"; # optional: without it the IMAP source stays off
      DynamicUser = true;
      StateDirectory = "housey";
      Restart = "always";
      RestartSec = 5;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };

  services.nginx.virtualHosts."housey.bjvanbemmel.nl" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3004";
      recommendedProxySettings = true;
    };
    # Server-sent events (new matches are pushed here): no buffering, long read timeout.
    locations."/events" = {
      proxyPass = "http://127.0.0.1:3004";
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_read_timeout 1h;
      '';
    };
  };
}
