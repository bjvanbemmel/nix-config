{ config, pkgs, ... }:

{
  home.packages = [
    # The nixpkgs wrapper unsets DISPLAY when NIXOS_OZONE_WL=1, which makes
    # Spotify run on native Wayland. There its CEF draws an unthemed fallback
    # title bar, so unset the variable to keep it on XWayland where mutter
    # draws the frame.
    (pkgs.spotify.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        wrapProgramShell $out/share/spotify/spotify \
          --unset NIXOS_OZONE_WL
      '';
    }))
  ];
}
