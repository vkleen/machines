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
  };
}
