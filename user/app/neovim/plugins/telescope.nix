{ config, pkgs, ... }:

{
  programs.nixvim.plugins.telescope = {
    enable = true;
  };
}
