{ config, pkgs, ... }:
{
  networking = {
    hostName = "boron";
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    useNetworkd = true;
    firewall = {
      enable = false;
    };
  };
}
