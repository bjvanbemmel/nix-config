{ config, pkgs, ... }:

{
  programs.nixvim.plugins.comment = {
    enable = true;

    settings = {
      opleader.line = "<C-_>";
      toggler.line = "<C-_>";
    };
  };
}
