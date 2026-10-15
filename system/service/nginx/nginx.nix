{ config, pkgs, ... }:

{
  services.nginx = {
    recommendedProxySettings = true;
    virtualHosts = {
      "q.bjvanbemmel.nl" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://10.139.57.1:8080/";
        };
      };
      "prowlarr.bjvanbemmel.nl" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://10.139.57.1:9696/";
        };
      };
      "flaresolverr.bjvanbemmel.nl" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://10.139.57.1:8191/";
        };
      };
      "pal.bjvanbemmel.nl" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:3030/";
        };
      };
      "_" = {
        default = true;
        rejectSSL = true;
        extraConfig = "return 444;";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "beau@tb.pro";
  };
}
