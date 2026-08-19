{ config, pkgs, ... }:

{
  environment.etc."ssh/forgejo-authorized-keys-command" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      exec ${pkgs.forgejo-lts}/bin/forgejo keys -c /var/lib/forgejo/custom/conf/app.ini -e git -u "$1" -t "$2" -k "$3"
    '';
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      AllowUsers = [ "beauv" "git" ];
      PasswordAuthentication = false;
    };
    extraConfig = ''
      Match User git
        AuthorizedKeysCommand /etc/ssh/forgejo-authorized-keys-command %u %t %k
        AuthorizedKeysCommandUser forgejo
      Match all
    '';
  };
}
