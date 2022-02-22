{ config, pkgs, lib, flake, ... }:
let
  inherit (builtins) substring;
  inherit (import ../../utils { inherit lib; }) private_address private_address6;
  machine_id = config.environment.etc."machine-id".text;

in {
  system.publicAddresses = [
    "45.32.153.151"
    "2001:19f0:6c01:21c1:5400:03ff:fec6:c9cd"
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
          address = "45.32.153.151";
          prefixLength = 22;
        } ];
        ipv6.addresses = [ {
          address = "2001:19f0:6c01:21c1:5400:03ff:fec6:c9cd";
          prefixLength = 64;
        } ];
      };
      "enp6s0" = {
        ipv4.addresses = [ {
          address = private_address 32 machine_id;
          prefixLength = 16;
        } ];
        mtu = 1450;
      };
    };
    firewall = {
      enable = true;
      trustedInterfaces = [ "enp6s0" ];
      allowPing = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      interfaces = {
        "boron-dsl" = {
          allowedUDPPorts = [ 3784 ];
        };
      };
    };
  };

  age.secrets.${config.networking.hostName} = {
    file = ../../secrets/wireguard + "/${config.networking.hostName}.age";
    mode = "0440";
    owner = "0";
    group = "systemd-network";
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
            PreferredSource = "2001:19f0:6c01:21c1:5400:03ff:fec6:c9cd";
            Gateway = "_ipv6ra";
          };
        }
        { routeConfig = {
            Destination = "169.254.169.254";
            PreferredSource = "45.32.153.151";
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
    #networks."40-boron" = {
    #  routes = [
    #    { routeConfig = {
    #        Destination = "2001:19f0:6c01:2bc5::/64";
    #      };
    #    }
    #    { routeConfig = {
    #        Destination = "45.77.54.162/32";
    #      };
    #    }
    #  ];
    #};
  };
}
