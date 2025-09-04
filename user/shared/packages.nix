{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    discord
    teams-for-linux
    obsidian
    rhythmbox
    bruno
    libreoffice-qt
    gimp
  ];
}
