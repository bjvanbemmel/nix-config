{ conf, pkgs, ... }:

{
  programs.git = {
    enable = true;
    extraConfig = {
      core = {
        editor = "nvim";
      };
    };
  };
}
