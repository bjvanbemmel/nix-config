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
