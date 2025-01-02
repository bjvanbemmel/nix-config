{ config, pkgs, ... }:

{
  programs.nixvim.plugins.treesitter = {
    enable = true;
    settings = {
      highlight.enable = true;
      indent.enable = true;
      incremental_highlight = true;
    };
  };
}
