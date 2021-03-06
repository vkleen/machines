{ config, pkgs, lib, ... }:

{
  imports = [
    ./wifi-secrets.nix
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
        ip6tables -A nixos-fw -p udp --dport 5353 -m pkttype --pkt-type multicast -j nixos-fw-accept
        iptables -A nixos-fw -p udp --dport 5353 -m pkttype --pkt-type multicast -j nixos-fw-accept

        iptables -I nixos-fw -s 94.16.123.211 -p tcp -m tcp --sport 8443 -j DROP
      '';
      extraStopCommands = ''
      '';
      logRefusedConnections = false;
    };

    # dhcpcd = {
    #   allowInterfaces = [ "wlan0" "eth-usb" "eth-dock" "wwan" "einsteinium" ];
    #   enable = true;
    #   extraConfig = ''
    #     metric 400
    #   '';
    # };

    wlanInterfaces = {
      "wlan0" = {
        device = "wlp1s0";
      };
    };

    interfaces = {
      "wlan0" = {
        useDHCP = true;
      };
      # "tap-vkleen" = {
      #   virtual = true;
      #   virtualType = "tap";
      #   virtualOwner = "vkleen";
      # };
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
          { publicKey = builtins.readFile ../wireguard/samarium.pub;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "127.0.0.2:51820";
            persistentKeepalive = 5;
          }
        ];
      };
      wg1 = {
        ips = [ "10.172.30.132/24" "2600:3c01:e002:8b9d:2469:eead::1/64" ];
        privateKeyFile = "/persist/private/bohrium";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../wireguard/plutonium.pub;
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
          { publicKey = builtins.readFile ../wireguard/europium.pub;
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

  systemd.services.iwd.environment = {
    # IWD_TLS_DEBUG = "on";
  };

  systemd.services.supplicant-wlan0.partOf = lib.mkForce [];

  services.resolved = {
    llmnr = "false";
  };

  services.udev.packages = [ pkgs.crda ];

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8153", ATTR{address}=="70:88:6b:8a:f1:5f", NAME:="eth-usb"
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

  systemd.services.udp2rawtunnel = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "Wireguard over udp2raw";
    serviceConfig = {
      User = "nobody";
      Group = "nogroup";
      AmbientCapabilities = "CAP_NET_RAW";
      NoNewPrivileges = true;
      ExecStart = "${pkgs.udp2raw}/bin/udp2raw -c -l127.0.0.2:51820 -r94.16.123.211:8443 --cipher-mode none --auth-mode none";
    };
  };

  # environment.etc."resolv.conf" = lib.mkForce {
  #   text = ''
  #     nameserver 127.0.0.1
  #     options edns0
  #   '';
  # };

  services.kresd = {
    enable = false;
    extraConfig = ''
      modules = { 'policy' }
      local ffi = require('ffi')
      local function denyAAAA(zone_list)
        local AC = require('ahocorasick')
        local tree = AC.create(zone_list)
        return function(state, query)
          local match = AC.match(tree, query:name(), false)
          if match ~= nil and query.stype == kres.type.AAAA then
            return policy.DENY
          end
          return nil
        end
      end

      policy.add(denyAAAA({ todname('netflix.com.'), todname('nflximg.net.'), todname('nflxvideo.net.'), todname('nflxso.net.'), todname('nflxext.com.') }))
      policy.add(policy.suffix(policy.STUB('127.0.0.53'), { todname('.') }))
    '';
  };
}
