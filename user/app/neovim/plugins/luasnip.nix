{ config, pkgs, ... }:

{
  programs.nixvim.plugins.luasnip = {
    enable = true;
  };
}
