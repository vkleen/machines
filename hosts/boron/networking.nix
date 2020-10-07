{ config, pkgs, lib, ... }:
{
  networking = {
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    useNetworkd = true;
    firewall = {
      enable = false;
    };
  };
}
