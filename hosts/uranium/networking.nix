{ ... }:
{
  networking = {
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      enable = false;
    };
  };
  systemd.network = {
    enable = true;
    netdevs."10-bond0" = {
      netdevConfig = {
        Kind = "bond";
        Name = "bond0";
        MACAddress = "7a:e4:08:c0:9c:aa";
      };
      bondConfig = {
        Mode = "802.3ad";
        MIIMonitorSec = "0.1";
        LACPTransmitRate = "fast";
        TransmitHashPolicy = "layer3+4";
        MinLinks = 1;
      };
    };
    networks = {
      "30-eno5np0" = {
        matchConfig.Name = "eno5np0";
        networkConfig.Bond = "bond0";
      };
      "30-eno6np1" = {
        matchConfig.Name = "eno6np1";
        networkConfig.Bond = "bond0";
      };
      "40-bond0" = {
        matchConfig.Name = "bond0";
        linkConfig.RequiredForOnline = "routable";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
      };
    };
  };
}
