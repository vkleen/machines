{ config, flake, pkgs, lib, ... }:
{
  networking = {
    useDHCP = false;
    useNetworkd = true;

    interfaces = {
      "eth0" = {
        useDHCP = true;
      };
    };

    firewall = {
      enable = false;
      allowPing = true;
    };

    hosts = {
      "45.33.37.163"   = [ "plutonium.kleen.org" ];
      "172.104.139.29" = [ "europium.kleen.org" ];
    };

    namespaces.enable = true;
  };

  systemd.network = {
    networks."40-eth0" = {
      networkConfig = {
        LLDP = "yes";
        EmitLLDP = "yes";
      };
    };
  };
}
