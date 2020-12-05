{ config, flake, pkgs, lib, ... }:
let
  ppp_interface = "wan";
in {
  imports = [
    flake.nixosModules.netns
    flake.nixosModules.upstream-container
  ];
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
    nameserver ::1
    search auenheim.kleen.org
  '';
  networking = {
    useDHCP = false;
    useNetworkd = true;

    vlans = {
      "auenheim" = {
        id = 11;
        interface = "eth0";
      };
      "auenheim-mgmt" = {
        id = 30;
        interface = "eth0";
      };
    };

    interfaces = {
      "eth0" = {
        useDHCP = false;
      };
      "auenheim" = {
        ipv4.addresses = [
          { address = "10.172.100.1"; prefixLength = 24; }
        ];
        ipv6.addresses = [
          { address = "2a01:7e01:e002:aa02::1"; prefixLength = 64; }
        ];
      };
      "mgmt" = {
        ipv4.addresses = [
          { address = "10.172.0.3"; prefixLength = 24; }
        ];
      };
      "upstream-mgmt" = {};
    };

    bridges = {
      "mgmt" = {
        interfaces = [ "auenheim-mgmt" ];
      };
    };

    nat = {
      enable = true;
      externalInterface = "wg-europium";
      internalInterfaces = [ "auenheim" ];
      internalIPs = [ "10.172.100.0/24" ];
    };

    firewall = {
      enable = true;
      allowPing = true;
      interfaces = {
        "auenheim" = {
          allowedUDPPorts = [ 53 ];
          allowedTCPPorts = [ 53 ];
        };
      };
      extraCommands = ''
        ip46tables -D FORWARD -j nixos-fw-forward 2>/dev/null || true
        ip46tables -F nixos-fw-forward 2> /dev/null || true
        ip46tables -X nixos-fw-forward 2> /dev/null || true

        ip46tables -N nixos-fw-forward
        ip46tables -A nixos-fw-forward -i auenheim -j ACCEPT
        ip46tables -A nixos-fw-forward -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

        ip6tables -A nixos-fw-forward -p icmpv6 --icmpv6-type redirect -j DROP
        ip6tables -A nixos-fw-forward -p icmpv6 --icmpv6-type 139 -j DROP
        ip6tables -A nixos-fw-forward -p icmpv6 -j ACCEPT

        ip46tables -A nixos-fw-forward -j DROP
        ip46tables -A FORWARD -j nixos-fw-forward

        ip46tables -A POSTROUTING -t mangle -o wg-europium -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
      '';
      extraStopCommands = ''
        ip46tables -D FORWARD -j nixos-fw-forward 2>/dev/null || true
        ip46tables -F nixos-fw-forward 2> /dev/null || true
        ip46tables -X nixos-fw-forward 2> /dev/null || true
      '';
    };

    hosts = {
      "45.33.37.163"   = [ "plutonium.kleen.org" ];
      "94.16.123.211"  = [ "samarium.kleen.org" ];
      "172.104.139.29" = [ "europium.kleen.org" ];
    };

    wireguard.interfaces = {
      wg-europium = {
        ips = [ "10.172.40.136/24" "2a01:7e01:e002:aa00:cc6b:36a1:0:1/64" ];
        privateKeyFile = "/persist/private/boron";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../../secrets/wireguard/europium.pub;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "europium.kleen.org:51820";
            persistentKeepalive = 1;
          }
        ];
        postSetup = ''
          ${pkgs.iproute}/bin/ip route add default via 10.172.40.1 dev wg-europium
          ${pkgs.iproute}/bin/ip -6 route add default via 2a01:7e01:e002:aa00:f8a1:f27f:0:1 dev wg-europium
        '';
        postShutdown = ''
          ${pkgs.iproute}/bin/ip route del default via 10.172.40.1 dev wg-europium
          ${pkgs.iproute}/bin/ip -6 route del default via 2a01:7e01:e002:aa00:f8a1:f27f:0:1 dev wg-europium
        '';
        socketNamespace = "wg_upstream";
        interfaceNamespace = "init";
      };
    };

    namespaces.enable = true;
  };

  virtualisation.upstream-container = {
    enable = true;
    config = {
      environment.noXlibs = true;
      networking = {
        useDHCP = false;
        useNetworkd = true;
        useHostResolvConf = false;
        interfaces = {
          "telekom" = {
            useDHCP = false;
          };
          "lte" = {
            useDHCP = true;
          };
          "mgmt-veth" = {
            useDHCP = false;
            ipv4.addresses = [
              { address = "10.172.0.4"; prefixLength = 24; }
            ];
          };
        };
        firewall = {
          enable = true;
          allowPing = true;
          extraCommands = ''
            ip46tables -F FORWARD
            ip46tables -A FORWARD -j DROP
            iptables -I FORWARD 1 -o lte -d 192.168.1.1 -j ACCEPT
            iptables -I FORWARD 2 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

            iptables -t mangle -F POSTROUTING
            iptables -t mangle -A POSTROUTING -o lte -j TTL --ttl-set 65
          '';
        };
        nat = {
          enable = true;
          externalInterface = "lte";
          internalInterfaces = [ "mgmt-veth" ];
          internalIPs = [ ];
        };
        inherit (config.networking) hosts;
      };
      systemd.network = {
        networks."40-lte" = {
          dhcpV4Config = {
            RouteMetric = 1024;
          };
          networkConfig = {
            DHCP = lib.mkForce "ipv4";
            LinkLocalAddressing = "no";
          };
        };
        networks."40-telekom" = {
          networkConfig.LinkLocalAddressing = "no";
        };
      };
      services.pppd = {
        enable = true;
        peers."telekom" = {
          enable = true;
          autostart = true;
          config = ''
            nodefaultroute
            ifname ${ppp_interface}
            lcp-echo-failure 1
            lcp-echo-interval 1
            maxfail 0
            mtu 1492
            mru 1492
            plugin rp-pppoe.so
            name telekom
            user 0024489473715511349841040001@t-online.de
            telekom
          '';
        };
      };
      environment.etc = {
        "ppp/ip-up" = {
          text = ''
            #!${pkgs.runtimeShell}
            ${pkgs.iproute}/bin/ip route add default via "$5" dev "${ppp_interface}" metric 512
          '';
          mode = "0555";
        };
      };
      services.resolved = {
        llmnr = "false";
      };
    };
    netns = "wg_upstream";
    preStartScript = ''
      ip link add name telekom link eth0 type vlan id 7
      ip link add dev upstream-mgmt type veth peer name mgmt-veth

      ip link set telekom netns wg_upstream
      ip link set upstream-mgmt master mgmt
      ip link set mgmt-veth netns wg_upstream

      ip link set upstream-mgmt up
    '';
    postStopScript = ''
      ip netns exec wg_upstream ip link del telekom || true
      ip link del upstream-mgmt || true
    '';

    bindMounts = {
      "/etc/ppp/pap-secrets" = { hostPath = "/persist/ppp/pap-secrets"; isReadOnly = true; };
      "/dev/ppp" = { isReadOnly = false; };
    };
    allowedDevices = [
      { node = "/dev/ppp"; modifier = "rw"; }
    ];
  };

  systemd.services = {
    "wireguard-wg-europium" = {
      after = [ "netns@wg_upstream.service" "upstream-container.service" ];
      bindsTo = [ "netns@wg_upstream.service" ];
    };
    "upstream@" = {
      requires = [ "netns@wg_upstream.service" ];
      after = [ "netns@wg_upstream.service" ];
      serviceConfig = {
        Type = "oneshot";
      };
      environment = {
        DEVPATH="%I";
      };
      script =''
        ${pkgs.iproute}/bin/ip link set dev "$(${pkgs.coreutils}/bin/basename "$DEVPATH")" netns wg_upstream
      '';
    };
  };

  services.dhcpd4 = {
    interfaces = [ "auenheim" ];
    enable = true;
    extraConfig = ''
      option subnet-mask 255.255.255.0;
      option broadcast-address 10.172.100.255;
      option routers 10.172.100.1;
      option domain-name "auenheim.kleen.org";
      subnet 10.172.100.0 netmask 255.255.255.0 {
        range 10.172.100.100 10.172.100.200;
        option domain-name-servers 10.172.100.1;
      }

      include "/persist/dhcpd4/dhcp-tsig";

      ddns-update-style standard;
      ddns-updates on;
      ddns-domainname "auenheim.kleen.org.";
      ddns-rev-domainname "in-addr.arpa";
      use-host-decl-names on;
      update-static-leases on;

      allow client-updates;
      allow unknown-clients;

      zone auenheim.kleen.org. {
        primary 127.0.0.2;
        key dhcp-tsig;
      }
      zone 100.172.10.in-addr.arpa. {
        primary 127.0.0.2;
        key dhcp-tsig;
      }

      host dptrp1 {
        hardware ethernet ac:89:95:f8:15:a3;
        fixed-address 10.172.100.20;
        ddns-hostname dptrp1;
      }
    '';
    machines = [
    ];
  };

  services.corerad = {
    enable = true;
    settings = {
      interfaces = [
        { name = "auenheim";
          advertise = true;
          prefix = [{ prefix = "::/64"; }];
          route = [{ prefix = "::/0"; }];
        }
      ];
    };
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv6.conf.default.forwarding" = true;
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv4.conf.default.forwarding" = true;
  };

  services.udev.extraRules = ''
    ATTRS{idVendor}=="12d1", ATTRS{idProduct}=="1f01", RUN+="${pkgs.usb_modeswitch}/bin/usb_modeswitch -J -v %s{idVendor} -p %s{idProduct}"
    KERNEL=="eth*", ATTR{address}=="58:2c:80:13:92:63", NAME="lte", TAG+="systemd", ENV{SYSTEMD_WANTS}="upstream@.service"
  '';

  systemd.network = {
    networks."40-eth0" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
    networks."40-auenheim-mgmt" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
    networks."40-upstream-mgmt" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
    networks."40-mgmt" = {
      routes = [
        { routeConfig = {
            Destination = "192.168.1.1/32";
            Gateway = "10.172.0.4";
          };
        }
      ];
    };
  };

  services.resolved = {
    enable = false;
  };

  services.unbound = {
    enable = true;
    interfaces = [ "127.0.0.1" "10.172.100.1" "::1" "2a01:7e01:e002:aa02::1" ];
    allowedAccess = [ "10.172.100.0/24" "127.0.0.0/24" ];
    extraConfig = ''
      server:
        local-zone: "10.in-addr.arpa." nodefault
        domain-insecure: "10.in-addr.arpa."
        do-not-query-localhost: no

      remote-control:
        control-enable: yes
        control-interface: /var/lib/unbound/control.socket

      stub-zone:
        name: auenheim.kleen.org
        stub-addr: 127.0.0.1@5353
        stub-first: yes
        stub-no-cache: yes

      stub-zone:
        name: 10.in-addr.arpa.
        stub-addr: 127.0.0.1@5353
        stub-first: no
        stub-no-cache: yes
    '';
  };

  services.knot = {
    enable = true;
    keyFiles = [
      "/persist/knot/keys/dhcp-tsig"
    ];
    extraConfig = ''
      server:
        listen: 127.0.0.1@5353
        listen: 127.0.0.2@53
        listen: ::1@5353
      acl:
        - id: update_acl
          key: dhcp-tsig
          action: update
      policy:
        - id: manual
          manual: on
      mod-onlinesign:
        - id: manual
          policy: manual
      mod-synthrecord:
        - id: ip6-forward
          type: forward
          prefix: ip6-
          ttl: 400
          network: ::/0
        - id: ip4-forward
          type: forward
          prefix: ip4-
          ttl: 400
          network: 0.0.0.0/0
      zone:
        - domain: auenheim.kleen.org
          storage: /var/lib/knot/zones
          module: [mod-synthrecord/ip4-forward, mod-synthrecord/ip6-forward, mod-onlinesign/manual]
          zonefile-sync: -1
          zonefile-load: none
          journal-content: all
          acl: update_acl
        - domain: 100.172.10.in-addr.arpa
          storage: /var/lib/knot/zones
          dnssec-signing: off
          zonefile-sync: -1
          zonefile-load: none
          journal-content: all
          acl: update_acl
      log:
        - target: syslog
          any: info
    '';
  };

  fileSystems."/var/lib/knot" = {
    device = "/persist/knot";
    options = [ "bind" ];
  };
}
