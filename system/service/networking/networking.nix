{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.eduvpn-client ];

  networking = {
    hosts = {
      "10.0.0.1" = [ "bjvanbemmel.local" ];
      "10.0.0.3" = [ "storage.bjvanbemmel.local" ];
      "10.139.57.1" = [ "vault.local" ];
    };
    networkmanager = {
      enable = true;
      plugins = [ pkgs.networkmanager-openvpn ];
    };
  };
}
