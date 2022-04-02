{pkgs, lib, ...}:
{
  networking = {
    bonds = {
      auenheim = {
        interfaces = [ "enP4p1s0f0" "enP4p1s0f1" ];
        driverOptions = {
          miimon = "100";
          mode = "balance-alb";
          xmit_hash_policy = "encap3+4";
        };
      };
    };
    useDHCP = false;
    interfaces.auenheim = {
      macAddress = "2c:09:4d:00:02:b0";
      useDHCP = true;
    };
    useNetworkd = true;
    firewall = {
      enable = false;
    };

    hosts = {
      "45.33.37.163"   = [ "plutonium.kleen.org" ];
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

  systemd.network = {
    networks."40-enP4p1s0f0" = {
      networkConfig = {
        LLDP = "yes";
        EmitLLDP = "yes";
      };
    };
    networks."40-enP4p1s0f1" = {
      networkConfig = {
        LLDP = "yes";
        EmitLLDP = "yes";
      };
    };
  };
}
