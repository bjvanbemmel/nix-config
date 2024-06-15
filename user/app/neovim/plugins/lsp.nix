{ config, pkgs, ... }:

{
  programs.nixvim.plugins.lsp = {
    enable = true;
    servers = {
      gopls.enable = true; # Golang
      nixd.enable = true; # Nix
      lua-ls.enable = true; # Lua
    };
  };
}
