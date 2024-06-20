{ config, pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      slang = "en,jp";
      alang = "jp,en";
      sub-font-size = 35;
      sub-pos = 90;
    };
  };
}
