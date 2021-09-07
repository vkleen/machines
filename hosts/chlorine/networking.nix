{pkgs, lib, ...}:
{
  networking = {
    useDHCP = false;
    interfaces.enP4p1s0f0.useDHCP = true;
    useNetworkd = true;
    firewall = {
      enable = false;
    };

    hosts = {
      "45.33.37.163"   = [ "plutonium.kleen.org" ];
      "94.16.123.211"  = [ "samarium.kleen.org" ];
      "172.104.139.29" = [ "europium.kleen.org" ];
    };

  #   wireguard.interfaces = {
  #     wg2 = {
  #       ips = [ "10.172.40.135/24" ];
  #       privateKeyFile = "/run/keys/chlorine";
  #       allowedIPsAsRoutes = false;
  #       peers = [
  #         { publicKey = builtins.readFile ../../secrets/wireguard/europium.pub;
  #           allowedIPs = [ "0.0.0.0/0" "::/0" ];
  #           endpoint = "europium.kleen.org:51820";
  #           persistentKeepalive = 5;
  #         }
  #       ];
  #     };
  #   };
  };
}
