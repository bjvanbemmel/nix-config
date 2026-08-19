{ config, pkgs, }:

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
    email = "beau@tb.pro";
  };
}
