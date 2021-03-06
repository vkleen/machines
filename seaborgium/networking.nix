{ config, pkgs, lib, ... }:

{
  # services.kresd = {
  #   enable = true;
  #   extraConfig = ''
  #     modules = { 'policy' }
  #     local ffi = require('ffi')
  #     local function genRR (state, req)
  #       local answer = req.answer
  #       local qry = req:current()
  #       answer:rcode(kres.rcode.NOERROR)
  #       answer:begin(kres.section.ANSWER)
  #       if qry.stype == kres.type.AAAA then
  #         answer:put(qry.sname, 900, answer:qclass(), kres.type.AAAA,
  #           '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1')
  #       elseif qry.stype == kres.type.A then
  #         answer:put(qry.sname, 900, answer:qclass(), kres.type.A, '\127\0\0\1')
  #       end
  #       return kres.DONE
  #     end
  #     policy.add(policy.suffix(policy.FLAGS({'NO_CACHE'}), policy.todnames({ 'hoogle.', 'local.', 'lan.' }) ))

  #     policy.add(policy.suffix(genRR, { todname('hoogle.') }))
  #     policy.add(policy.suffix(genRR, { todname('docs.gl.local.') }))

  #     policy.add(policy.suffix(policy.STUB('192.168.12.1'), { todname('lan.') }))
  #     policy.add(policy.suffix(policy.STUB('8.8.8.8'), { todname('.') }))
  #   '';
  # };
  networking = {
    # nameservers = [ "127.0.0.1" ];

    iproute2.enable = true;
    firewall = {
      enable = true;
      checkReversePath = false;
      trustedInterfaces = [ "wg0" "wg1" ];
      allowPing = true;
      extraCommands = ''
        ip6tables -A nixos-fw -p udp --dport 5353 -m pkttype --pkt-type multicast -j nixos-fw-accept
        iptables -A nixos-fw -p udp --dport 5353 -m pkttype --pkt-type multicast -j nixos-fw-accept

        iptables -I nixos-fw -s 94.16.123.211 -p tcp -m tcp --sport 8443 -j DROP

        iptables -t mangle -F POSTROUTING
        iptables -t mangle -A POSTROUTING -o wwan -j TTL --ttl-set 65
      '';
      extraStopCommands = ''
      '';
      logRefusedConnections = false;
    };

    dhcpcd = {
      allowInterfaces = [ "wlan0" "eth-usb" "wwan" "einsteinium" ];
      enable = true;
      extraConfig = ''
        metric 400
      '';
    };

    wlanInterfaces = {
      "wlan0" = {
        device = "wlp1s0";
      };
    };

    interfaces = {
      "tap-vkleen" = {
        virtual = true;
        virtualType = "tap";
        virtualOwner = "vkleen";
        ipv4.addresses =  [ {
          address = "10.1.1.254";
          prefixLength = 24;
        } ];
      };
    };

    hosts = {
      "45.33.37.163"  = [ "plutonium.kleen.org" ];
      "94.16.123.211" = [ "samarium.kleen.org" ];
    };

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.172.20.128/24" "2a03:4000:21:6c9:ba9c:b01a:0a7d:1/80"];
        privateKeyFile = "/private/seaborgium";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../wireguard/samarium.pub;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "127.0.0.2:51820";
          }
        ];
      };
      wg1 = {
        ips = [ "10.172.30.128/24" "2600:3c01:e002:8b9d:b01a:0a7d::1/64" ];
        privateKeyFile = "/private/seaborgium";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../wireguard/plutonium.pub;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "plutonium.kleen.org:51820";
          }
        ];
      };
    };

   # connman = {
   #   enable = true;
   #   enableVPN = false;
   #   extraConfig = ''
   #     AllowHostnameUpdates = false
   #     BackgroundScanning = false
   #     FallbackNameservers = 8.8.8.8,8.8.4.4
   #     EnableOnlineCheck = false
   #   '';
   #   extraFlags = [ "--nodnsproxy" ];
   #   networkInterfaceBlacklist = [
   #     "vmnet" "vboxnet" "virbr" "ifb" "ve" "tap-vkleen"
   #     "wlan-monitor" "wg0" "wg1" "bat0" "gre-plutonium"
   #   ];
   # };

   # wireless = {
   #   interfaces = [ "wlan" ];
   #   userControlled = {
   #     enable = true;
   #     group = "network";
   #   };
   #   networks = {
   #     "USC Guest Wireless" = {};
   #   };
   # };

    wireless = {
      iwd.enable = true;
    };


    # supplicant = {
    #   "wlan" = {
    #     extraConf = ''
    #       ap_scan=1
    #     '';
    #     configFile = {
    #       path = "/etc-persistent/wpa_supplicant.conf";
    #       writable = true;
    #     };

    #     userControlled = {
    #       enable = true;
    #       group = "network";
    #     };
    #   };
    # };
  };

  systemd.services.iwd.environment = {
    # IWD_TLS_DEBUG = "on";
  };

  systemd.services.supplicant-wlan0.partOf = lib.mkForce [];

  services.udev.packages = [ pkgs.crda ];

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8153", ATTR{address}=="70:88:6b:8a:f1:5f", NAME:="eth-usb"
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

  # security.wrappers = {
  #   udp2raw = {
  #     source = "${pkgs.udp2raw}/bin/udp2raw";
  #     owner = "nobody";
  #     group = "nogroup";
  #     capabilities = "cap_net_raw+ep";
  #   };
  # };

}
