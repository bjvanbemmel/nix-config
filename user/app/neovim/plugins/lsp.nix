{ config, pkgs, ... }:

{
  programs.nixvim.plugins.lsp = {
    enable = true;
    servers = {
      gopls.enable = true; # Golang
      nixd.enable = true; # Nix
      lua-ls.enable = true; # Lua
      omnisharp.enable = true; # C#
      docker-compose-language-service.enable = true; # Docker compose files
      dockerls.enable = true; # Dockerfile
    };
  };
}
