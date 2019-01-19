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
    '';
  };
  networking = {
    nameservers = [ "127.0.0.1" ];

    iproute2.enable = true;
    firewall.checkReversePath = false;

    dhcpcd = {
      allowInterfaces = [ "wlan" "eth-usb" ];
      enable = true;
      # extraConfig = ''
      #   static domain_name_servers=8.8.8.8 8.8.4.4
      # '';
    };

    wlanInterfaces = {
      "wlan" = {
        device = "wlp1s0";
      };
      "wlan-monitor" = {
        device = "wlp1s0";
        type = "monitor";
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


#    connman = {
#      enable = true;
#      enableVPN = false;
#      extraConfig = ''
#        AllowHostnameUpdates = false
#        BackgroundScanning = false
#	FallbackNameservers = 8.8.8.8,8.8.4.4
#	EnableOnlineCheck = false
#      '';
#      networkInterfaceBlacklist = [
#        "vmnet" "vboxnet" "virbr" "ifb" "ve"
#	"wlan-monitor"
#      ];
#    };

#    wireless = {
#      enable = true;
#      networks = {
#        "Hotel_BB" = {};
#      };
#      interfaces = [ "wlan" ];
#      userControlled = {
#        enable = true;
#	group = "network";
#      };
#    };

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
    IWD_TLS_DEBUG = "on";
  };

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

#  systemd.services.supplicant-wlan.partOf = lib.mkForce [];

  services.udev.packages = [ pkgs.crda ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8153", ATTR{address}=="00:e0:4c:68:34:f7", NAME:="eth-usb"
  '';
}
