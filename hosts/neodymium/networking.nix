{ config, pkgs, ... }:
{
  networking = {
    hostName = "neodymium";
    useDHCP = false;
    nameservers = [
      "8.8.8.8" "2001:4860:4860::8888"
    ];
    defaultGateway = {
      address = "202.61.248.1";
      interface = "ens3";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
    interfaces = {
      "ens3".ipv4.addresses = [ {
        address = "202.61.250.130";
        prefixLength = 22;
      } ];
      "ens3".ipv6.addresses = [
      { address = "2a03:4000:54:9b1::1";
        prefixLength = 64;
      }
      { address = "2a03:4000:54:9b1::25";
        prefixLength = 64;
      }
      ];
    };
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 25 80 443 ];
      allowedUDPPorts = [ 51820 ];
    };
  };
}
