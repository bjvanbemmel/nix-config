{ pkgs, lib, ... }:

let
  # Set after first deploy on bjvanbemmel: cat /etc/wireguard/wg0.pub
  bjvanbelmmPubKey = "nAt/8asnGogcu2ygJR/7QRP7jJKFK2UzoI+srm0frXY=";
in

{
  system.activationScripts.wireguard-keygen = ''
    if [ ! -f /etc/wireguard/wg0.key ]; then
      mkdir -p /etc/wireguard
      ${pkgs.wireguard-tools}/bin/wg genkey > /etc/wireguard/wg0.key
      chmod 600 /etc/wireguard/wg0.key
      ${pkgs.wireguard-tools}/bin/wg pubkey < /etc/wireguard/wg0.key > /etc/wireguard/wg0.pub
    fi
  '';

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.2/32" ];
    privateKeyFile = "/etc/wireguard/wg0.key";
    peers = lib.optionals (bjvanbelmmPubKey != null) [
      {
        publicKey = bjvanbelmmPubKey;
        endpoint = "bjvanbemmel.nl:51820";
        allowedIPs = [ "10.100.0.1/32" ];
        persistentKeepalive = 25;
      }
    ];
  };
}
