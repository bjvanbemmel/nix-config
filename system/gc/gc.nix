{ conf, pkgs, ... }:

{
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-generations +10";
  };
}
