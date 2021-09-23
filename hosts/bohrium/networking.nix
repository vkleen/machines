

{ config, pkgs, lib, ... }:

{
  networking = {
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      enable = true;
      checkReversePath = false;
      trustedInterfaces = [ "wg0" "wg1" ];
      allowPing = true;
      extraCommands = ''
        ip6tables -A nixos-fw -p udp --dport 5353 -j nixos-fw-accept
        iptables -A nixos-fw -p udp --dport 5353 -j nixos-fw-accept

        iptables -I nixos-fw -s 94.16.123.211 -p tcp -m tcp --sport 8443 -j DROP
      '';
      extraStopCommands = ''
      '';
      logRefusedConnections = false;

      allowedTCPPorts = [ 9998 9999 ];
    };

    wlanInterfaces = {
      "wlan0" = {
        device = "wlp1s0";
      };
    };

    bonds = {
      "lan" = {
        interfaces = [ "wlan0" "eth-dock" ];
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
      "lan" = {
        # ipv4.addresses = [
        #   { address = "10.172.100.101"; prefixLength = 24; }
        # ];
        useDHCP = true;
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
      "45.33.37.163"   = [ "plutonium.kleen.org" ];
      "94.16.123.211"  = [ "samarium.kleen.org" ];
      "172.104.139.29" = [ "europium.kleen.org" ];
    };

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.172.20.132/24" "2a03:4000:21:6c9:ba9c:2469:eead:1/80"];
        privateKeyFile = "/run/secrets/bohrium";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../../wireguard/samarium.pub;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "samarium.kleen.org:51820";
            persistentKeepalive = 5;
          }
        ];
        postSetup = ''
          ${pkgs.iproute}/bin/ip link set dev wg0 mtu 1300
        '';
      };
      wg1 = {
        ips = [ "10.172.30.132/24" "2600:3c01:e002:8b9d:2469:eead::1/64" ];
        privateKeyFile = "/run/secrets/bohrium";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../../wireguard/plutonium.pub;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "plutonium.kleen.org:51820";
            persistentKeepalive = 5;
          }
        ];
      };
      wg2 = {
        ips = [ "10.172.40.132/24" "2a01:7e01:e002:aa00:2469:eead::1/64" ];
        privateKeyFile = "/run/secrets/bohrium";
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
  };

  services.resolved = {
    llmnr = "false";
  };

  services.udev.packages = [ pkgs.crda ];

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8153", ATTR{address}=="d0:c0:bf:48:d8:e7", NAME:="eth-dock"
  '';

  programs.mtr.enable = true;

  fileSystems."/var/lib/iwd" = {
    device = "/persist/iwd";
    options = [ "bind" ];
  };
}
