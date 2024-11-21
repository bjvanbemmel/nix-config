{ config, pkgs, ... }:

{
  programs.brave = {
    enable = true;
    extensions = [
      "lkhiljgmbeecmljiogckofcalncmfnfo" # Migaku
    ];
  };
}
