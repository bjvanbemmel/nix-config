{ config, pkgs, ... }:

{
  networking = {
    hosts = {
      "10.0.0.1" = [ "bjvanbemmel.local" ];
      "10.0.0.3" = [ "storage.bjvanbemmel.local" ];
    };
    networkmanager.enable = true;
    nameservers = [
      "192.168.2.254"
      "1.1.1.1"
    ];
  };
}
