{ config, pkgs, ... }:

{
  networking = {
    networkmanager.enable = true;
    nameservers = [
      "192.168.2.254"
      "1.1.1.1"
    ];
  };
}
