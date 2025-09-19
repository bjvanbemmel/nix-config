{ config, pkgs, ... }:

{
  programs.nixvim.plugins.oil = {
    enable = true;
  };

  programs.nixvim.plugins.oil-git-status = {
    enable = true;
    settings = {
      show_ignored = true;
    };
  };
}
