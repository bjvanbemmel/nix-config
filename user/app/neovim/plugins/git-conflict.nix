{ config, pkgs, ... }:

{
  programs.nixvim.plugins.git-conflict = {
    enable = true;
  };
}
