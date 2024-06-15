{ config, pkgs, ... }:

{
  programs.nixvim.plugins.comment = {
    enable = true;

    settings = {
      opleader.line = "<leader>c";
      toggler.line = "<leader>c";
    };
  };
}
