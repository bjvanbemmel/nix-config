{ config, pkgs, ... }:

{
  services.nginx = {
    virtualHosts = {
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
