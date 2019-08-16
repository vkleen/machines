{ config, pkgs, lib, ... }:

{
  services.kresd = {
    enable = true;
    extraConfig = ''
      modules = { 'policy' }
      local ffi = require('ffi')
      local function genRR (state, req)
        local answer = req.answer
        local qry = req:current()
        answer:rcode(kres.rcode.NOERROR)
        answer:begin(kres.section.ANSWER)
        if qry.stype == kres.type.AAAA then
          answer:put(qry.sname, 900, answer:qclass(), kres.type.AAAA,
            '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1')
        elseif qry.stype == kres.type.A then
          answer:put(qry.sname, 900, answer:qclass(), kres.type.A, '\127\0\0\1')
        end
        return kres.DONE
      end
      policy.add(policy.suffix(policy.FLAGS({'NO_CACHE'}), policy.todnames({ 'hoogle.', 'local.', 'lan.' }) ))

      policy.add(policy.suffix(genRR, { todname('hoogle.') }))
      policy.add(policy.suffix(genRR, { todname('docs.gl.local.') }))

      policy.add(policy.suffix(policy.STUB('192.168.12.1'), { todname('lan.') }))
      policy.add(policy.suffix(policy.STUB('8.8.8.8'), { todname('.') }))
    '';
  };
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

        iptables -t mangle -F POSTROUTING
        iptables -t mangle -A POSTROUTING -o wwan -j TTL --ttl-set 65
      '';
      extraStopCommands = ''
      '';
    };

    dhcpcd = {
      allowInterfaces = [ "wlan0" "eth-usb" "wwan" ];
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
            endpoint = "samarium.kleen.org:51820";
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

  # system.activationScripts.var =
  #   let networks = [
  #         { name = "eduroam.config"; config = ''
  #             [service_eduroam]
  #             Type=wifi
  #             Name=eduroam
  #             EAP=peap
  #             AnonymousIdentity=anonymous@usc.edu
  #             Phase2=MSCHAPV2
  #             Identity=kleen@usc.edu
  #             #Passphrase=%pass USC/kleen%
  #           '';
  #         }

  #         { name = "USCSecure.config"; config = ''
  #             [service_USCSecure]
  #             Type=wifi
  #             Name=USC Secure Wireless
  #             EAP=peap
  #             AnonymousIdentity=anonymous
  #             Phase2=MSCHAPV2
  #             Identity=kleen
  #             #Passphrase=%pass USC/kleen%
  #           '';
  #         }
  #       ];
  #       mkNetworkFile = {name, config}:
  #         let file = pkgs.writeText (lib.replaceStrings [" "] ["-"] name) config;
  #         in ''
  #           mkdir -p -m 0700 /var/lib/connman
  #           cp "${file}" /var/lib/connman/"${name}".temp
  #           mv /var/lib/connman/"${name}".temp /var/lib/connman/"${name}"
  #         '';
  #       mkNetworkFiles = map mkNetworkFile networks;
  #   in lib.concatStringsSep "\n" mkNetworkFiles;

  system.activationScripts.var =
    let networks = [
          { name = "eduroam.8021x"; config = ''
              [Security]
              EAP-Method=PEAP
              EAP-Identity=anonymous@usc.edu
              EAP-PEAP-Phase2-Method=MSCHAPV2
              EAP-PEAP-Phase2-Identity=kleen@usc.edu
              #EAP-PEAP-Phase2-Password=%pass eduroam/kleen@usc.edu%
              [Settings]
              Autoconnect=True
            '';
          }

          { name = "USC Secure Wireless.8021x"; config = ''
              [Security]
              EAP-Method=PEAP
              EAP-Identity=anonymous
              EAP-PEAP-Phase2-Method=MSCHAPV2
              EAP-PEAP-Phase2-Identity=kleen
              #EAP-PEAP-Phase2-Password=%pass USC/kleen%
              [Settings]
              Autoconnect=True
            '';
          }
        ];
        mkNetworkFile = {name, config}:
          let file = pkgs.writeText (lib.replaceStrings [" "] ["-"] name) config;
          in ''
            mkdir -p -m 0700 /var/lib/iwd
            cp "${file}" /var/lib/iwd/"${name}".temp
            mv /var/lib/iwd/"${name}".temp /var/lib/iwd/"${name}"
          '';
        mkNetworkFiles = map mkNetworkFile networks;
    in lib.concatStringsSep "\n" mkNetworkFiles;

  systemd.services.supplicant-wlan0.partOf = lib.mkForce [];

  services.udev.packages = [ pkgs.crda ];

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8153", ATTR{address}=="70:88:6b:87:74:b6", NAME:="eth-usb"
  '';
}
