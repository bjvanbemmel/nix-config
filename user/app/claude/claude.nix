{ config, pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    mcpServers = {
      obsidian = {
        command = "npx";
        args = [ "@bitbonsai/mcpvault@latest" "/home/beauv/Documents/obsidian/Minerva" ];
      };
      youtube = {
        command = "npx";
        args = [ "-y" "zubeid-youtube-mcp-server" ];
        env = {
          YOUTUBE_API_KEY = "AIzaSyCxCLAhtEKAqLjJsXm-ZJopXuPl_ydsx2o"; # Get from https://console.cloud.google.com/apis/credentials
        };
      };
      wolfram = {
        type = "http";
        url = "https://agenttools.wolfram.com/mcp";
      };
    };
  };
}
