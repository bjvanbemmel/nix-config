{ config, pkgs, ... }:

{
  programs.nixvim.plugins.oil = {
    enable = true;
  };
}
