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
      });
    extensions = [
      "ajopnjidmegmdimjlfnijceegpefgped" # BetterTTV
      "ammjkodgmmoknidbanneddgankgfejfh" # 7TV
      "fadndhdgpmmaapbmfcknlfgcflmmmieb" # FrankerFaceZ
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
    ];
  };
}
