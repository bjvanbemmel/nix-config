{ ... }:

# Self-hosted reMarkable cloud. Tablet must be pointed at https://rm.bjvanbemmel.nl (see rmfakecloud docs for your firmware).
# Data lives in /var/lib/rmfakecloud. The first user is created through the web UI.
let
  PORT = 3005;
  DOMAIN = "rm.bjvanbemmel.nl";
in
{
  services.rmfakecloud = {
    enable = true;
    port = PORT;
    storageUrl = "https://${DOMAIN}";
  };

  services.nginx.virtualHosts."${DOMAIN}" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      client_max_body_size 512M;
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString PORT}";
      proxyWebsockets = true;
    };
  };
}
