{ ... }:
{
  networking = {
    useDHCP = false;
    interfaces.enP4p1s0f0 = {
      macAddress = "2c:09:4d:00:02:b0";
      useDHCP = true;
    };
    useNetworkd = true;
    firewall = {
      enable = false;
    };
  };
}
