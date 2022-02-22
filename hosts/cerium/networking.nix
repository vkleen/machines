{ config, pkgs, lib, ... }:
let
  inherit (builtins) substring;
  inherit (import ../../utils/ints.nix { inherit lib; }) hexToInt;
  machine_id = config.environment.etc."machine-id".text;

  private_address = let
    chars12 = substring 0 2 machine_id;
    chars34 = substring 2 2 machine_id;

    octet1 = hexToInt chars12;
    octet2 = hexToInt chars34;
  in "10.32.${builtins.toString octet1}.${builtins.toString octet2}";
in {
  system.publicAddresses = [
    "45.32.154.225"
    "2001:19f0:6c01:284a:5400:03ff:fec6:c9b0"
  ];
  networking = {
    useDHCP = false;
    useNetworkd = true;
    nameservers = [
      "2001:19f0:300:1704::6"
    ];
    interfaces = {
      "enp1s0" = {
        useDHCP = true;
        ipv4.addresses = [ {
          address = "45.32.154.225";
          prefixLength = 22;
        } {
          address = "45.77.54.162";
          prefixLength = 32;
        } ];
        ipv6.addresses = [ {
          address = "2001:19f0:6c01:284a:5400:03ff:fec6:c9b0";
          prefixLength = 64;
        } {
          address = "2001:19f0:6c01:2bc5::1";
          prefixLength = 64;
        } ];
      };
      "enp6s0" = {
        ipv4.addresses = [ {
          address = private_address;
          prefixLength = 16;
        } ];
        mtu = 1450;
      };
    };
    firewall = {
      enable = true;
      trustedInterfaces = [ "wg0" "enp6s0" ];
      allowPing = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 2;
  };
  systemd.network = {
    networks."40-enp1s0" = {
      routes = [
        { routeConfig = {
            Destination = "2001:19f0:ffff::1/128";
            PreferredSource = "2001:19f0:6c01:284a:5400:03ff:fec6:c9b0";
            Gateway = "_ipv6ra";
          };
        }
        { routeConfig = {
            Destination = "169.254.169.254";
            PreferredSource = "45.32.154.225";
            Gateway = "_dhcp4";
          };
        }
      ];
      ipv6AcceptRAConfig = {
        UseAutonomousPrefix = "no";
        UseOnLinkPrefix = "no";
      };
    };
    networks."40-enp6s0" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
  };
}
