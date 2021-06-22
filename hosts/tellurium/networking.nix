{ config, flake, pkgs, lib, ... }:
{
  networking = {
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      enable = true;
      checkReversePath = false;
      trustedInterfaces = [ ];
      allowPing = true;
      extraCommands = ''
      '';
      extraStopCommands = ''
      '';
      logRefusedConnections = false;
    };

    interfaces = {
      "eth0" = {
        useDHCP = true;
      };
    };

    hosts = {
      "45.33.37.163"   = [ "plutonium.kleen.org" ];
      "94.16.123.211"  = [ "samarium.kleen.org" ];
      "172.104.139.29" = [ "europium.kleen.org" ];
    };
  };

  services.resolved = {
    llmnr = "false";
  };
}
