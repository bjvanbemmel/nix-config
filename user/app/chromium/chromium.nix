{ config, pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    # package = pkgs.ungoogled-chromium;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "lkhiljgmbeecmljiogckofcalncmfnfo" # Migaku
    ];
  };
}
