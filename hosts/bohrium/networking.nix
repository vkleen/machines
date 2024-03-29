{ config, pkgs, lib, flake, ... }:
let
  inherit (flake.inputs.utils.lib) private_address mkV4 mkV6 mkHosts;
in {
  networking = {
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      enable = true;
      checkReversePath = false;
      trustedInterfaces = [ "europium" ];
      allowPing = true;
      extraCommands = ''
      '';
      extraStopCommands = ''
      '';
      logRefusedConnections = false;

      allowedTCPPorts = [ ];
    };

    wlanInterfaces = {
      "wlan0" = {
        device = "wlp1s0";
      };
    };

    bonds = {
      "lan" = {
        interfaces = [ "wlan0" "eth-dock" "eth-usb" ];
        driverOptions = {
          miimon = "1000";
          mode = "active-backup";
          primary_reselect = "always";
        };
      };
    };

    interfaces = {
      "wlan0" = {
        useDHCP = false;
      };
      "eth-dock" = {
        useDHCP = false;
      };
      "eth-usb" = {
        useDHCP = false;
      };
      "lan" = {
        # ipv4.addresses = [
        #   { address = "10.172.100.101"; prefixLength = 24; }
        # ];
        useDHCP = true;
      };
      "carbon" = {
        useDHCP = false;
        ipv4.addresses = [
          { address = "10.11.99.2"; prefixLength = 24; }
        ];
      };
      "mgmt" = {
        useDHCP = true;
      };
    };

    # defaultGateway = {
    #   address = "10.172.100.1";
    # };

    # nameservers = [ "10.172.100.1" ];

    hosts = {
    } // mkHosts flake [ "boron" "europium" "lanthanum" "cerium" ];

    wireguard.interfaces = {
      europium = {
        ips = [ "10.172.40.132/24" "2a01:7e01:e002:aa00:2469:eead::1/64" ];
        privateKeyFile = "/run/agenix/bohrium";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../../wireguard/europium.pub;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "europium.kleen.org:51820";
            persistentKeepalive = 5;
          }
        ];
      };
    };

    wireless = {
      iwd.enable = true;
    };
  };
  age.secrets.bohrium.file = ../../secrets/wireguard/bohrium.age;

  systemd.services.supplicant-wlan0.partOf = lib.mkForce [];

  systemd.network = {
    networks."40-eth-dock" = {
      networkConfig.PrimarySlave = true;
    };

    networks."40-mgmt" = {
      dhcpV4Config.UseRoutes = false;
      networkConfig = {
        DHCP = lib.mkForce "ipv4";
        LinkLocalAddressing = "no";
      };
      routes = [
        { routeConfig = {
            Destination = "192.168.88.1/32";
            Gateway = "10.172.0.4";
          };
        }
      ];
    };

    links."40-bnep0" = {
      matchConfig = {
        MACAddress = "60:f2:62:17:59:7f";
        Type = "bluetooth";
      };
      linkConfig = {
        AlternativeName = "dptrp1";
      };
    };
    networks."40-bnep0" = {
      linkConfig = {
        Unmanaged = "yes";
        Multicast = "yes";
        RequiredForOnline = "no";
      };
      networkConfig = {
        DHCP = "no";
        MulticastDNS = "resolve";
        LinkLocalAddressing = "ipv6";
      };
    };
  };

  services.resolved = {
    llmnr = "false";
  };

  services.udev.packages = [ pkgs.crda ];

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8153", ATTR{address}=="d0:c0:bf:48:d8:e7", NAME:="eth-dock"
    SUBSYSTEM=="net", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8153", ATTR{address}=="00:e0:4c:68:01:b2", NAME:="eth-usb"
    SUBSYSTEM=="net", ATTRS{idVendor}=="04b3", ATTRS{idProduct}=="4010", ATTR{address}=="0a:85:21:7d:9d:62", NAME:="carbon"
  '';

  programs.mtr.enable = true;

  fileSystems."/var/lib/iwd" = {
    device = "/persist/iwd";
    options = [ "bind" ];
  };
}
