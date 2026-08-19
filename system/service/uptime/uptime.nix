{ config, pkgs, ... }:

{
  services.uptime-kuma = {
    enable = true;
    settings = {
      PORT = toString 3001;
      UPTIME_KUMA_DB_TYPE = "sqlite";
    };
  };
  
  services.nginx.virtualHosts = {
    "status.bjvanbemmel.nl" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:3001";
        extraConfig = ''
          proxy_set_header Host $host;
        '';
      };
    };
  };
}
