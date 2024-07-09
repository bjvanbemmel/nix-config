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
      tsserver.enable = true; # TypeScript (and JavaScript)
      volar.enable = true; # Vue
      tailwindcss.enable = true; # Tailwind
      jsonls.enable = true; # JSON
      eslint.enable = true; # ESLint
      html.enable = true; # HTML
      sqls.enable = true; # SQL
    };
  };
}
