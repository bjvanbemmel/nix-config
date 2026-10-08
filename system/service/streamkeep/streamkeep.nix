{ pkgs, ... }:

# Pauses vault's qBittorrent while Jellyfin streams.
# Secrets live out of band in /etc/streamkeep.env (root, mode 0600):
#   JELLYFIN_API_KEY=...
#   QBIT_USER=...
#   QBIT_PASS=...
let
  streamkeep = pkgs.buildGoModule {
    pname = "streamkeep";
    version = "0.1.0";

    src = pkgs.fetchgit {
      url = "https://git.bjvanbemmel.nl/bjvanbemmel/streamkeep";
      rev = "9257c9356c0452c9314305cbc3b79db9373a7091";
      hash = "sha256-3gKDXw6SUmTt6SkkAfd7VEAvVh16IkolE5QaPdBvtL4=";
    };

    vendorHash = null;
  };
in
{
  systemd.services.streamkeep = {
    description = "Pause qBittorrent on vault while Jellyfin streams";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" "jellyfin.service" "wg-quick-vault.service" ];

    environment = {
      JELLYFIN_URL = "http://localhost:8096";
      QBIT_URL = "http://10.139.57.1:8080";
    };

    serviceConfig = {
      ExecStart = "${streamkeep}/bin/streamkeep";
      EnvironmentFile = "/etc/streamkeep.env";
      DynamicUser = true;
      StateDirectory = "streamkeep";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
