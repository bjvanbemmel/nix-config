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
          YOUTUBE_API_KEY = ""; # Get from https://console.cloud.google.com/apis/credentials
        };
      };
      wolfram = {
        type = "http";
        url = "https://agenttools.wolfram.com/mcp";
      };
    };
    # Math router settings: auto-detect math questions and suggest workflow
    settings = {
      hooks = {
        UserPromptSubmit = [
          {
            matcher = "*";
            hooks = [
              {
                type = "command";
                command = "jq -r '.message // .text // \"\"' | grep -iq 'solve\\|equation\\|derive\\|integral\\|circle\\|tangent\\|geometry\\|function\\|parametric\\|limit\\|extrema\\|cosine\\|sine\\|derivative' && echo '{\"systemMessage\": \"💡 Tip: Use `/workflow math-router \\\"your problem\\\"` to auto-route to the right model tier (Haiku/Sonnet/Opus).\"}' || echo '{}'";
                statusMessage = "Math question detected";
                async = true;
              }
            ];
          }
        ];
      };
    };
  };

  # Deploy math-router workflow file
  home.file.".claude/workflows/math-router.js" = {
    source = /home/beauv/Documents/obsidian/Minerva/.claude/workflows/math-router.js;
  };
}
