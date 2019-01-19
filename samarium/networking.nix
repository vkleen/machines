{ config, ... }:
{
  imports = [
    ./kresd.nix
  ];

  networking = {
    hostName = "samarium";
    useDHCP = false;
    defaultGateway = {
      address = "94.16.120.1";
      interface = "ens3";
    };
    interfaces = {
      "ens3".ipv4.addresses = [ {
        address = "94.16.123.211";
        prefixLength = 22;
      } ];
      "ens3".ipv6.addresses = [ {
        address = "2a03:4000:21:6c9::1";
        prefixLength = 64;
      } ];
    };
    firewall = {
      enable = true;
      trustedInterfaces = [  ];
      allowPing = true;
      allowedTCPPorts = [ 25 80 443 ];
      allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
    };
  };
}
