{ lib, ... }:
{
  networking = {
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      enable = true;
      checkReversePath = false;
      trustedInterfaces = [ ];
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
        device = "wlp170s0";
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
        useDHCP = true;
      };
    };

    wireless = {
      iwd.enable = true;
    };
  };

  systemd.services.supplicant-wlan0.partOf = lib.mkForce [ ];

  systemd.network = {
    networks."40-eth-dock" = {
      networkConfig.PrimarySlave = true;
    };
    networks."40-eth-usb" = {
      networkConfig.PrimarySlave = true;
    };
  };

  services.resolved = {
    llmnr = "false";
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8153", ATTR{address}=="98:fd:b4:9b:d9:89", NAME:="eth-dock"
    SUBSYSTEM=="net", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8153", ATTR{address}=="00:e0:4c:68:01:b2", NAME:="eth-usb"
  '';

  environment.persistence."/persist".directories = [
    "/var/lib/iwd"
  ];
}
