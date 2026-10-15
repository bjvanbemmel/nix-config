{ conf, pkgs, lib, ... }:

{
  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "sonarr";
    group = "users";
  };

  systemd.services.sonarr.serviceConfig.UMask = lib.mkForce "0002";

  services.nginx.virtualHosts = {
    "sonarr.bjvanbemmel.nl" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:8989";
      };
    };
  };
}
