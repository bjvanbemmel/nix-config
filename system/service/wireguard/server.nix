{ pkgs, ... }:

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

    peers = [
      {
        # framework — after first deploy, get with: cat /etc/wireguard/wg0.pub (on framework)
        publicKey = "<FRAMEWORK_WG_PUBKEY>";
        allowedIPs = [ "10.100.0.2/32" ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];

  # Ollama is only reachable from WireGuard peers
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 11434 ];
}
