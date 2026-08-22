{ conf, pkgs, ... }:

{
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        IdentitiesOnly = true;
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
      };

      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/github";
      };

      "git.bjvanbemmel.nl" = {
        HostName = "git.bjvanbemmel.nl";
        User = "forgejo";
        IdentityFile = "~/.ssh/git.bjvanbemmel";
      };

      "storage" = {
        HostName = "storage.bjvanbemmel.nl";
        User = "beauv";
        IdentityFile = "~/.ssh/storage.bjvanbemmel";
      };

      "bjvanbemmel" = {
        HostName = "bjvanbemmel.nl";
        User = "beauv";
        IdentityFile = "~/.ssh/bjvanbemmel";
      };
    };
  };
}
