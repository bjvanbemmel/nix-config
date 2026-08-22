{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      AllowUsers = [ "beauv" "forgejo" ];
      PasswordAuthentication = false;
    };
  };
}
