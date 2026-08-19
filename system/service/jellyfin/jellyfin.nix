{ conf, pkgs, ... }:

{
  users.groups.jellyfin = {};

  users.users.jellyfin = {
    isSystemUser = true;
    group = "jellyfin";
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jellyfin";
  };

  services.nginx.virtualHosts = {
    "watch.bjvanbemmel.nl" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:8096";
      };
    };
  };
}
