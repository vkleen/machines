{ config, pkgs, lib, ... }:
{
  networking = {
    iproute2.enable = true;
    firewall.enable = false;

    hosts = {
      "45.33.37.163"   = [ "plutonium.kleen.org" ];
      "94.16.123.211"  = [ "samarium.kleen.org" ];
      "172.104.139.29" = [ "europium.kleen.org" ];
    };

    wireguard.interfaces = {
      wg2 = {
        ips = [ "10.172.40.135/24" ];
        privateKeyFile = "/run/keys/chlorine";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../wireguard/europium.pub;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "europium.kleen.org:51820";
            persistentKeepalive = 5;
          }
        ];
      };
    };
  };
}
