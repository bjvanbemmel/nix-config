{ conf, pkgs, ... }:

{
  services.seerr = {
    enable = true;
  };

  services.nginx.virtualHosts = {
    "seerr.bjvanbemmel.nl" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:5055";
      };
    };
  };
}
