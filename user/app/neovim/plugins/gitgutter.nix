{ config, pkgs, ... }:

{
  programs.nixvim.plugins.gitgutter = {
    enable = true;
    settings = {
      highlight_linenrs = true;
    };
  };
}
