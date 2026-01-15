{ conf, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      core.editor = "nvim";
      credential.helper = "store";
      user.name = "bjvanbemmel";
      user.email = "beauvanbemmel@live.nl";
    };
  };
}
