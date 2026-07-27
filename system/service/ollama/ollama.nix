{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    host = "10.100.0.1"; # Only listen on the WireGuard interface.
    loadModels = [
      "mistral-nemo:12b"
      "qwen2.5-coder:1.5b"
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
      CPUQuota = "400%";   # cap at 4 of 8 cores, leaving headroom for the OS
      MemoryHigh = "14G";  # soft ceiling — throttles instead of killing
      MemoryMax = "20G";   # hard ceiling as a last-resort system safety net
    };
  };
}
