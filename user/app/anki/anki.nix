{ config, pkgs, ... }:

{
  programs.anki = {
    enable = true;
    theme = "followSystem";
    style = "anki";
    addons = [
      pkgs.ankiAddons.passfail2
      (pkgs.ankiAddons.anki-connect.withConfig {
        config = {
          apiKey = null;
          apiLogPath = null;
          webBindAddress = "127.0.0.1";
          webBindPort = 8765;
          webCorsOrigin = "*";
          webCorsOriginList = [
            "http://localhost"
            "app://obsidian.mb"
          ];
        };
      })
    ];
  };
}
