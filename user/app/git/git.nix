{ conf, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "bjvanbemmel";
    userEmail = "beauvanbemmel@live.nl";
    extraConfig = {
      core = {
        editor = "nvim";
      };
    };
  };
}
