{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./users.nix
    ];

  nix = {
    nixPath = [
      "nixpkgs=${pkgs.path}"
    ];

    binaryCaches = [
      "https://cache.nixos.org/"
      "https://ntqrfoedxliczzavdvuwhzvhkxbhxbpv.cachix.org"
    ];

    binaryCachePublicKeys = [
      "seaborgium.1:0cDg6+fSZ4Z4L7T24SPPal5VN4m51P5o2NDfUycbKmo="
      "freyr.1:d8VFt+9VtvwWAMKEGEERpZtWWh8Z3bDf+O2HrOLjBYQ="
      "ntqrfoedxliczzavdvuwhzvhkxbhxbpv.cachix.org-1:reOmDDtgU13EasMsy993sq3AuzGmXwfSxNTYPfGf3Hc="
    ];
  };

  nix.buildCores = 4;
  nix.maxJobs = 4;

  nix.useSandbox = true;
  nix.trustedUsers = [ "root" ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
  };

  networking = {
    hostName = "freyr";
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    useDHCP = false;
    dhcpcd = {
      allowInterfaces = [ "wwan" ];
      enable = true;
    };
    interfaces = {
      "ap0".ipv4.addresses = [ {
        address = "192.168.12.1";
        prefixLength = 24;
      } ];
      "enp0s25".ipv4.addresses = [ {
        address = "192.168.24.1";
        prefixLength = 24;
      } ];
      "enp2s0".ipv4.addresses = [ {
        address = "192.168.25.1";
        prefixLength = 24;
      } ];
      "wwan".useDHCP = true;
    };
    wlanInterfaces = {
      "wlan" = {
        device = "wlp3s0";
      };
      "ap0" = {
        device = "wlp3s0";
        mac = "02:00:00:00:00:02";
      };
    };
    firewall = {
      enable = true;
      trustedInterfaces = [ "enp0s25" "enp2s0" "wlp3s0" "ap0" "wg0" ];
      allowPing = true;
      extraCommands = ''
        iptables -t mangle -F POSTROUTING
        iptables -t mangle -A POSTROUTING -o wwan -j TTL --ttl-set 65

        iptables -A FORWARD -i wwan -d 192.168.12.0/24 -j ACCEPT
        iptables -A FORWARD -i wwan -d 192.168.24.0/24 -j ACCEPT
        iptables -A FORWARD -i ap0 -s 192.168.12.0/24 -j ACCEPT
        iptables -A FORWARD -i enp0s25 -s 192.168.24.0/24 -j ACCEPT
        iptables -A FORWARD -i enp2s0 -s 192.168.24.0/24 -j ACCEPT
        iptables -t nat -A POSTROUTING -o wwan -j MASQUERADE
      '';
    };
    extraHosts = ''
      192.168.12.1 freyr freyr.lan
      192.168.24.1 freyr freyr.lan
    '';

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.172.20.129/24" "2a03:4000:21:6c9:ba9c:cc8e:b00c:1/80" ];
        privateKeyFile = "/private/freyr";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../wireguard/samarium.pub;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "samarium.kleen.org:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  services.hostapd = {
    enable = true;
    interface = "ap0";
    ssid = "Auenheim2";
    wpa = false;
    channel = 1;
    hwMode = "a";
    extraConfig = ''
      country_code=US
      ieee80211n=1
      ieee80211ac=0

      ieee80211d=1
      ieee80211h=1

      ht_capab=[HT40+][LDPC][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][DSSS_CCK-40]

      channel=44

      wpa=2
      wpa_passphrase=flugsimulator
      wpa_key_mgmt=WPA-PSK
      wpa_pairwise=TKIP CCMP
      rsn_pairwise=CCMP
    '';
  };

  services.dnsmasq = {
    enable = true;
    servers = [ "8.8.8.8" "8.8.4.4" ];
    resolveLocalQueries = true;
    extraConfig = ''
      listen-address=192.168.12.1,192.168.24.1,192.168.25.1,::1,127.0.0.1
      no-resolv
      bind-dynamic
      dhcp-range=set:12,192.168.12.3,192.168.12.254,255.255.255.0,24h
      dhcp-range=set:24,192.168.24.3,192.168.24.254,255.255.255.0,24h
      dhcp-range=set:25,192.168.25.3,192.168.25.254,255.255.255.0,24h
      dhcp-option-force=tag:12,option:router,192.168.12.1
      dhcp-option-force=tag:12,option:dns-server,192.168.12.1
      dhcp-option-force=tag:24,option:router,192.168.24.1
      dhcp-option-force=tag:24,option:dns-server,192.168.24.1
      dhcp-option-force=tag:25,option:router,192.168.25.1
      dhcp-option-force=tag:25,option:dns-server,192.168.25.1
      dhcp-option-force=option:mtu,1500

      dhcp-host=2c:09:4d:00:02:af,talos-bmc
      dhcp-host=2c:09:4d:00:02:ad,chlorine

      enable-tftp
      tftp-root=/var/lib/pxe/chlorine

      cache-size=1000
      local=/lan/
      domain=lan
      no-hosts
      addn-hosts = ${pkgs.writeText "dnsmasq-hosts" ''
        192.168.12.1 freyr freyr.lan
        192.168.24.1 freyr freyr.lan
        192.168.25.1 freyr freyr.lan
      ''}
    '';
  };

  time.timeZone = "America/Los_Angeles";

  boot.kernelPackages = pkgs.linuxPackages_latest.extend (self: super: {
    kernel = super.kernel.override {
      kernelPatches = super.kernel.kernelPatches ++ [
        { name = "ath_regd_optional.patch";
          patch = ./ath_regd_optional.patch;
        }
      ];
      structuredExtraConfig = {
        ATH_USER_REGD = "y";
      };
    };
  });
  boot.supportedFilesystems = [ ];
  boot.zfs = {
    enableUnstable = true;
    forceImportRoot = false;
    forceImportAll = false;
  };
  networking.hostId = "cc8eb00c";

  environment.systemPackages = with pkgs; [
    wget vim zsh pciutils iw
    tmux mosh
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
  };

  services.tor = {
    enable = true;
    client.enable = true;
    relay.enable = false;
    hiddenServices = {
      ssh.map = [
        { port = 22; }
      ];
    };
  };

  services.xserver.enable = false;

  programs.zsh.enable = true;

  services.udev.packages = [ pkgs.crda ];
  services.udev.extraRules = ''
    ATTRS{idVendor}=="12d1", ATTRS{idProduct}=="1f01", RUN+="${pkgs.usb_modeswitch}/bin/usb_modeswitch -J -v %s{idVendor} -p %s{idProduct}"
    KERNEL=="eth*", ATTR{address}=="58:2c:80:13:92:63", NAME="wwan"
  '';

  security.sudo.configFile =
  ''
    Defaults:root,%wheel env_keep+=TERMINFO_DIRS
    Defaults:root,%wheel env_keep+=TERMINFO
    Defaults env_keep+=SSH_AUTH_SOCK
    Defaults !lecture,insults,rootpw

    root        ALL=(ALL) SETENV: ALL
    %wheel      ALL=(ALL:ALL) SETENV: ALL
  '';

  services.ntp.enable = false;
  services.chrony.enable = true;
  services.chrony.servers = [
    "0.north-america.pool.ntp.org"
    "1.north-america.pool.ntp.org"
    "2.north-america.pool.ntp.org"
    "3.north-america.pool.ntp.org"
  ];
  services.chrony.extraConfig = ''
    bindcmdaddress 127.0.0.1
    bindcmdaddress ::1
    port 0
    rtcsync
  '';
}
