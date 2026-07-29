{ config, pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    mcpServers = {
      obsidian = {
        command = "npx";
        args = [ "@bitbonsai/mcpvault@latest" "/home/beauv/Documents/obsidian/Minerva" ];
      };
      wolfram = {
        type = "http";
        url = "https://agenttools.wolfram.com/mcp";
      };
    };
  };
}
