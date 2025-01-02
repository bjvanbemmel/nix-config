{ config, pkgs, ... }:

{
  programs.nixvim.plugins.lsp = {
    enable = true;
    servers = {
      gopls.enable = true; # Golang
      nixd.enable = true; # Nix
      lua_ls.enable = true; # Lua
      omnisharp.enable = true; # C#
      docker_compose_language_service.enable = true; # Docker compose files
      dockerls.enable = true; # Dockerfile
      ts_ls.enable = true; # TypeScript (and JavaScript)
      volar.enable = true; # Vue
      tailwindcss.enable = true; # Tailwind
      jsonls.enable = true; # JSON
      eslint.enable = true; # ESLint
      html.enable = true; # HTML
      cssls.enable = true; # CSS
      sqls.enable = true; # SQL
      pyright.enable = true; # Python
      bashls.enable = true; # Bash
    };
  };
}
