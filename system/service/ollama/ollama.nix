{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    loadModels = [
      "mistral-nemo:12b"
      "qwen2.5-coder:7b"
    ];
    user = "ollama";
    group = "users";
  };
}
