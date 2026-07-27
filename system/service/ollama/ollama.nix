{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    # Only listen on the WireGuard interface — firewall restricts access further
    host = "10.100.0.1";
    loadModels = [
      "qwen2.5-coder:7b"
    ];
    user = "ollama";
    group = "users";
  };

  # wg0 must be up before Ollama starts — it binds to the WireGuard IP
  systemd.services.ollama = {
    after = [ "wireguard-wg0.service" ];
    requires = [ "wireguard-wg0.service" ];
  };
}
