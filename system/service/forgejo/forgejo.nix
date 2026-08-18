{ config, pkgs, ... }:

let
  PORT = 3000;
  DOMAIN = "git.bjvanbemmel.nl";
in
{
  services.nginx = {
    enable = true;
    virtualHosts.${DOMAIN} = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
          client_max_body_size 512M;
      '';
      locations."/" = {
        proxyPass = "http://localhost:${toString PORT}";
      };
    };
  };

  security.acme.acceptTerms = true;

  services.forgejo = {
    enable = true;
    package = pkgs.forgejo-lts;
    group = "forgejo";
    user = "forgejo";
    lfs = {
      enable = true;
      contentDir = "/import/forgejo/data/lfs";
    };
    settings = {
      server = {
        DOMAIN = "${toString DOMAIN}";
        ROOT_URL = "https://${DOMAIN}/";
        HTTP_PORT = PORT;
        SSH_PORT = 22;
      };
      service.DISABLE_REGISTRATION = false; #TODO: set to true after creating admin
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
    };
  };
}
