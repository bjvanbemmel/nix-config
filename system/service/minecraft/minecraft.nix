{ config, pkgs, ... }:

{
  services.minecraft-server = {
    enable = true;
    package = pkgs.papermc;
    eula = true;
    declarative = true;
    dataDir = "/import/minecraft";
    serverProperties = {
      server-port = 3002;
      difficulty = 2;
      gamemode = 0;
      max-players = 20;
      motd = "For diamonds, we mine.";
      enable-rcon = true;
    };
    jvmOpts = "-Xms4092M -Xmx4092M";
  };

  services.nginx = {
    streamConfig = ''
      upstream minecraft_backend {
        server 127.0.0.1:3002;
      }

      server {
        listen 25565;
        proxy_pass minecraft_backend;
        proxy_timeout 10m;
        proxy_connect_timeout 5s;
      }
    '';
  };
}
