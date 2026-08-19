{ config, pkgs, lib, ... }:

let
  PORT = 3000;
  DOMAIN = "git.bjvanbemmel.nl";
in
{
  services.nginx = {
    enable = true;
    virtualHosts."${DOMAIN}" = {
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
        SSH_PORT = lib.head config.services.openssh.ports;
        SSH_USER = "git";
        SSH_CREATE_AUTHORIZED_KEYS_FILE = false;
      };
      service.DISABLE_REGISTRATION = true;
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
    };
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.default = {
      enable = true;
      name = "prometheus";
      url = "http://localhost:3000/";
      settings = {};
      token = "LKxvLef-6lshZS-taBOVQWWUZCSLa30eA5Bnuht2hfB"; # Use agentix
      labels = [
          "ubuntu-latest:docker://golang:1.26.6-alpine"
          "ubuntu-22.04:docker://golang:1.26.6-alpine"
          "ubuntu-20.04:docker://golang:1.26.6-alpine"
          "ubuntu-latest:docker://node:26-alpine"
          "ubuntu-22.04:docker://node:26-alpine"
          "ubuntu-20.04:docker://node:26-alpine"
      ];
    };
  };
}
