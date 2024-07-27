{ ... }:
{
  networking = {
    useDHCP = false;
    interfaces.enP49p1s0f0np0 = {
      macAddress = "98:f2:b3:c3:0b:00";
      useDHCP = true;
    };
    useNetworkd = true;
    firewall = {
      enable = false;
    };
  };
}
