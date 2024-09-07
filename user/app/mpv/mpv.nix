{ config, pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      slang = "en,jp";
      alang = "jp,jpn,en,eng";
      sub-font-size = 35;
      sub-pos = 90;
    };
  };
}
