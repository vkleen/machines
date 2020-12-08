{ config, pkgs, lib, ... }:

{
  imports = [
    ../../secrets/wifi.nix
  ];

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
        useDHCP = true;
      };
    };

    hosts = {
      "45.33.37.163"   = [ "plutonium.kleen.org" ];
      "94.16.123.211"  = [ "samarium.kleen.org" ];
      "172.104.139.29" = [ "europium.kleen.org" ];
    };

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.172.20.132/24" "2a03:4000:21:6c9:ba9c:2469:eead:1/80"];
        privateKeyFile = "/persist/private/bohrium";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../../secrets/wireguard/samarium.pub;
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
        privateKeyFile = "/persist/private/bohrium";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../../secrets/wireguard/plutonium.pub;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "plutonium.kleen.org:51820";
            persistentKeepalive = 5;
          }
        ];
      };
      wg2 = {
        ips = [ "10.172.40.132/24" "2a01:7e01:e002:aa00:2469:eead::1/64" ];
        privateKeyFile = "/persist/private/bohrium";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../../secrets/wireguard/europium.pub;
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

  systemd.services.supplicant-wlan0.partOf = lib.mkForce [];

  systemd.network = {
    networks."40-eth-dock" = {
      networkConfig.PrimarySlave = true;
    };
  };

  services.resolved = {
    llmnr = "false";
  };

  services.udev.packages = [ pkgs.crda ];

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8153", ATTR{address}=="00:50:b6:ec:74:02", NAME:="eth-dock"
    ATTRS{idVendor}=="12d1", ATTRS{idProduct}=="1f01", RUN+="${pkgs.usb_modeswitch}/bin/usb_modeswitch -J -v %s{idVendor} -p %s{idProduct}"
    KERNEL=="eth*", ATTR{address}=="58:2c:80:13:92:63", NAME="wwan"
    SUBSYSTEM=="net", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="4ee3", ATTRS{serial}=="FA6CN0301735", NAME:="einsteinium"
  '';

  programs.mtr.enable = true;
  programs.captive-browser = {
    enable = true;
    interface = "wlan0";
    browser = lib.concatStringsSep " " [
      ''${pkgs.chromium}/bin/chromium''
      ''--user-data-dir=$XDG_RUNTIME_DIR/.chromium-captive''
      ''--proxy-server="socks5://$PROXY"''
      ''--host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE localhost"''
      ''--no-first-run''
      ''--new-window''
      ''--incognito''
      ''http://plutonium.kleen.org''
    ];
  };

  # systemd.services.udp2rawtunnel = {
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   description = "Wireguard over udp2raw";
  #   serviceConfig = {
  #     User = "nobody";
  #     Group = "nogroup";
  #     AmbientCapabilities = "CAP_NET_RAW";
  #     NoNewPrivileges = true;
  #     ExecStart = "${pkgs.udp2raw}/bin/udp2raw -c -l127.0.0.2:51820 -r94.16.123.211:8443 --cipher-mode none --auth-mode none";
  #   };
  # };

  fileSystems."/var/lib/iwd" = {
    device = "/persist/iwd";
    options = [ "bind" ];
  };
}
