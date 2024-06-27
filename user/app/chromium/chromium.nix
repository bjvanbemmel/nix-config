{ config, pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = (
      pkgs.chromium.override {
        commandLineArgs = [
          "--enable-features=VaapiVideoDecodeLinuxGL"
          "--ignore-gpu-blocklist"
          "--enable-zero-copy"
        ];
        enableWideVine = true;
      });
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "lkhiljgmbeecmljiogckofcalncmfnfo" # Migaku
    ];
  };
}
