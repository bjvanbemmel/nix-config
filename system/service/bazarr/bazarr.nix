{ conf, pkgs, lib, ... }:

{
  services.bazarr = {
    enable = true;
    openFirewall = true;
    user = "bazarr";
    group = "users";
  };

  systemd.services.bazarr.serviceConfig.UMask = lib.mkForce "0002";

  services.nginx.virtualHosts = {
    "bazarr.bjvanbemmel.nl" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:6767";
      };
    };
  };
}
