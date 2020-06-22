{ config, pkgs, ... }:
{
  networking = {
    hostName = "boron";
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      enable = false;
    };
  };
}
