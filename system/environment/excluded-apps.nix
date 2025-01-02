{ config, pkgs, ... }:

{
  environment.gnome.excludePackages = with pkgs; [
    gnome-music
  ];
}
