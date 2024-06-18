{ config, pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "lkhiljgmbeecmljiogckofcalncmfnfo" # Migaku
    ];
  };
}
