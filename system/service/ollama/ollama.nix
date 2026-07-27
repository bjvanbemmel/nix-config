{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    host = "10.100.0.1"; # Only listen on the WireGuard interface.
    loadModels = [
      "qwen2.5-coder:14b"
    ];
    user = "ollama";
    group = "users";
  };

  systemd.services.ollama = {
    after = [ "wireguard-wg0.service" ];
    requires = [ "wireguard-wg0.service" ];
  };
}
