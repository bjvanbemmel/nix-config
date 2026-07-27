{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    host = "10.100.0.1"; # Only listen on the WireGuard interface.
    loadModels = [
      "qwen2.5-coder:7b"
    ];
    user = "ollama";
    group = "users";
    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "1"; # one request at a time — single user, saves RAM
    };
  };

  systemd.services.ollama = {
    after = [ "wireguard-wg0.service" ];
    requires = [ "wireguard-wg0.service" ];
    serviceConfig = {
      CPUQuota = "600%";   # cap at 6 of 8 cores (75%)
      MemoryHigh = "18G";  # soft ceiling — 75% of 24 GB
      MemoryMax = "21G";   # hard ceiling as a last-resort system safety net
    };
  };
}
