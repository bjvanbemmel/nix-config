{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    discord
    teams-for-linux
    beekeeper-studio
    obsidian
    rhythmbox
    bruno
  ];
}
