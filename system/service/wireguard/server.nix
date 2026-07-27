{ pkgs, lib, ... }:

let
  # Set after first deploy on framework: cat /etc/wireguard/wg0.pub
  frameworkPubKey = null;
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
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/etc/wireguard/wg0.key";
    peers = lib.optionals (frameworkPubKey != null) [
      {
        publicKey = frameworkPubKey;
        allowedIPs = [ "10.100.0.2/32" ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 11434 ];
}
