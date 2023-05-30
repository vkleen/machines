{ ... }:
{
  networking = {
    useDHCP = false;
    interfaces.enP4p1s0f0 = {
      useDHCP = true;
    };
    useNetworkd = true;
    firewall = {
      enable = false;
    };
  };
}
