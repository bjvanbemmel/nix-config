{ config, pkgs, lib, ... }:

let
 wallpaper = fetchTree {
   type = "file";
   url = "https://wallpaper.bjvanbemmel.nl";
   narHash = "sha256-3wtS1YNIXmRRlP4wYCQT2JvIxLxkBVeE/cXhBZnT2DU=";
 };
in
{
  home.packages = with pkgs; [
    gnomeExtensions.appindicator
    adw-gtk3
  ];

  imports = [
    ./default-apps.nix
    ./keybindings.nix
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      enable-hot-corners = true;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      natural-scroll = false;
    };
    
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,close";
    };

   "org/gnome/desktop/background" = {
     picture-uri = "file://" + wallpaper.outPath;
     picture-uri-dark = "file://" + wallpaper.outPath;
   };

    # Japanese input as well as English (with modifier key)
    "org/gnome/desktop/input-sources" = with lib.hm.gvariant; {
      mru-sources = [ (mkTuple [ "xkb" "us+altgr-intl" ]) (mkTuple [ "ibus" "anthy" ]) ];
      sources = [ (mkTuple [ "xkb" "us+altgr-intl" ]) (mkTuple [ "ibus" "anthy" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Console.desktop"
      ];

      disable-user-extensions = false;

      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "system-monitor@gnome-shell-extensions.gcampax.github.com"
        "caffeine@patapon.info"
      ];
    };
  };
}
