{ pkgs, lib, ... }:
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
