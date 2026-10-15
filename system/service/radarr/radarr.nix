{ conf, pkgs, lib, ... }:

{
  services.radarr = {
    enable = true;
    openFirewall = true;
    user = "radarr";
    group = "users";
  };

  systemd.services.radarr.serviceConfig.UMask = lib.mkForce "0002";

  services.nginx.virtualHosts = {
    "radarr.bjvanbemmel.nl" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:7878";
      };
    };
  };
}
