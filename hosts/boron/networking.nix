{ config, flake, pkgs, lib, ... }:
let
  ppp_interface = "wan";

  inherit (flake.inputs.utils.lib) private_address mkV4 mkV6 getPublicV6 lists mkHosts;
  machine_id = config.environment.etc."machine-id".text;

  nft_ruleset = let
    globalTcpPorts =
         lib.lists.map builtins.toString config.networking.firewall.allowedTCPPorts
      ++ lib.lists.map ({from,to}: "${builtins.toString from}-${builtins.toString to}") config.networking.firewall.allowedTCPPortRanges;
    globalUdpPorts =
         lib.lists.map builtins.toString config.networking.firewall.allowedUDPPorts
      ++ lib.lists.map ({from,to}: "${builtins.toString from}-${builtins.toString to}") config.networking.firewall.allowedUDPPortRanges;

    interfaceTcpPorts = i: lib.lists.map builtins.toString config.networking.firewall.interfaces.${i}.allowedTCPPorts;
    interfaceUdpPorts = i: lib.lists.map builtins.toString config.networking.firewall.interfaces.${i}.allowedUDPPorts;
  in ''
    define icmp_protos = { ipv6-icmp, icmp, igmp }

    table inet filter {
      chain input {
        type filter hook input priority filter
        policy drop
        
        iifname { lo } accept
        ct state { related, established} accept

        meta l4proto ipv6-icmp icmpv6 type nd-redirect drop
        meta l4proto $icmp_protos accept

        ${lib.strings.concatStringsSep "\n" (lib.attrsets.mapAttrsToList
          (i: _: ''
            ${lib.strings.optionalString (interfaceUdpPorts i != [])
              "iifname { ${i} } meta l4proto udp udp dport { ${lib.strings.concatStringsSep "," (interfaceUdpPorts i)} } accept"}
            ${lib.strings.optionalString (interfaceTcpPorts i != [])
              "iifname { ${i} } meta l4proto tcp tcp dport { ${lib.strings.concatStringsSep "," (interfaceTcpPorts i)} } accept"}
          '')
          config.networking.firewall.interfaces)}

        meta l4proto tcp tcp dport { ${lib.strings.concatStringsSep "," globalTcpPorts} } accept
        meta l4proto udp udp dport { ${lib.strings.concatStringsSep "," globalUdpPorts} } accept

        meta l4proto udp ip6 daddr fe80::/64 udp dport 546 accept
      }

      chain forward {
        type filter hook forward priority filter
        policy drop
        iifname { auenheim } accept
        ct state { related, established } accept

        meta l4proto ipv6-icmp icmpv6 type nd-redirect drop
        meta l4proto $icmp_protos accept
      }
    }

    table inet raw {
      chain rpfilter {
        fib saddr . mark oif != 0 return
        meta nfproto ipv4 meta l4proto udp udp sport 67 udp dport 68 return
        meta nfproto ipv4 meta l4proto udp ip saddr 0.0.0.0 ip daddr 255.255.255.255 udp sport 68 udp dport 67 return
        counter drop
      }
      chain prerouting {
        type filter hook prerouting priority raw
        policy accept
        jump rpfilter
      }
    }
    table ip mss_clamp {
      chain postrouting {
        type filter hook postrouting priority mangle
        policy accept
        oifname { wg-europium, neodymium, freerange, lanthanum-dsl, lanthanum-lte, cerium-dsl, cerium-lte } meta l4proto tcp tcp flags & (syn|rst) == syn tcp option maxseg size set rt mtu
      }
    }
    table ip nat {
      chain prerouting {
        type nat hook prerouting priority dstnat
        policy accept

        iifname { auenheim } meta mark set 0x1
      }
      chain postrouting {
        type nat hook postrouting priority srcnat
        policy accept

        oifname { wg-europium } mark 0x1 masquerade
        oifname { neodymium } mark 0x1 masquerade
        oifname { forstheim } mark 0x1 masquerade
        oifname { celluloid } mark 0x1 masquerade
        oifname { freerange } snat to 206.83.40.96
      }
    }
  '';
in {
  environment.systemPackages = [
    pkgs.bfd pkgs.nftables
  ];

  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
    nameserver ::1
    search auenheim.kleen.org
  '';
  system.publicAddresses = [
#    (mkV4 "100.64.101.37")
    (mkV6 "2a06:e881:9008::1")
  ];
  networking = {
    useDHCP = false;
    useNetworkd = true;

    vlans = {
      "auenheim" = {
        id = 11;
        interface = "eth0";
      };
      "forstheim" = {
        id = 12;
        interface = "eth0";
      };
      "celluloid" = {
        id = 13;
        interface = "eth0";
      };
      "auenheim-mgmt" = {
        id = 30;
        interface = "eth0";
      };
      "zte" = {
        id = 33;
        interface = "eth0";
      };
      "apc" = {
        id = 31;
        interface = "eth0";
      };
      "ilo" = {
        id = 32;
        interface = "eth0";
      };
      "lte-if" = {
        id = 8;
        interface = "eth0";
      };
      "telekom" = {
        id = 7;
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
          { address = "2a06:e881:9008::1"; prefixLength = 64; }
        ];
      };
      "forstheim" = {
        ipv4.addresses = [
          { address = "10.172.12.1"; prefixLength = 24; }
        ];
        ipv6.addresses = [
          { address = "2a06:e881:9008:000c::1"; prefixLength = 64; }
        ];
      };
      "celluloid" = {
        ipv4.addresses = [
          { address = "10.172.13.1"; prefixLength = 24; }
        ];
        ipv6.addresses = [
          { address = "2a06:e881:9008:000d::1"; prefixLength = 64; }
        ];
      };
      "apc" = {
        ipv4.addresses = [
          { address = "10.172.31.1"; prefixLength = 24; }
        ];
        ipv6.addresses = [];
      };
      "ilo" = {
        ipv4.addresses = [
          { address = "10.172.32.1"; prefixLength = 24; }
        ];
        ipv6.addresses = [];
      };
      "mgmt" = {
        useDHCP = true;
        macAddress = "5a:1d:49:77:c9:26";
      };
      "lte-bridge" = {
        useDHCP = true;
      };
      "zte" = {
        useDHCP = false;
        ipv4.addresses = [
          { address = "192.168.1.2"; prefixLength = 24; }
        ];
        ipv6.addresses = [];
      };
    };

    bridges = {
      "mgmt" = {
        interfaces = [ "auenheim-mgmt" "upstream-mgmt" ];
      };
      "lte-bridge" = {
        interfaces = [ "lte-if" "upstream-lte" "ltens" ];
      };
    };

    nftables = {
      enable = true;
      ruleset = nft_ruleset;
    };

    firewall = {
      enable = false;
      allowPing = true;
      interfaces = {
        "auenheim" = {
          allowedUDPPorts = [ 53 69 123 ];
          allowedTCPPorts = [ 53 69 8883 ];
        };
        "zte" = {
          allowedUDPPorts = [ 123 ];
        };
        "wg-europium" = {
          allowedTCPPorts = [ config.services.rmfakecloud.port ];
        };
        "neodymium" = {
          allowedTCPPorts = [ config.services.rmfakecloud.port config.services.paperless.port ];
        };
      };
    };

    hosts = {
    } // mkHosts flake [ "europium" "neodymium" ];

    wireguard.interfaces = {
      wg-europium = {
        ips = [ "10.172.40.136/24" ];
        privateKeyFile = "/run/agenix/boron";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../../wireguard/europium.pub;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "[${lists.head (getPublicV6 flake "europium")}]:51820";
            persistentKeepalive = 1;
          }
        ];
      };
      neodymium = {
        ips = [ "10.172.50.136/24" ];
        privateKeyFile = "/run/agenix/boron";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../../wireguard/neodymium.pub;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "[${lists.head (getPublicV6 flake "neodymium")}]:51820";
            persistentKeepalive = 1;
          }
        ];
      };
      #freerange = {
      #  ips = [ "100.64.101.37/27" ];
      #  privateKeyFile = "/run/agenix/freerange";
      #  allowedIPsAsRoutes = false;
      #  peers = [
      #    { publicKey = "enMJtnjeb3AFY9v4OybvnM0Hvt4xZE0lPJ8exizfFHs=";
      #      allowedIPs = [ "0.0.0.0/0" "::/0" ];
      #      endpoint = "[2a0f:9400:fa0::91]:36745";
      #    }
      #  ];
      #};
    };

    namespaces.enable = true;
  };
  age.secrets.boron = {
    file = ../../secrets/wireguard/boron.age;
    mode = "0440";
    owner = "0";
    group = "systemd-network";
  };
  age.secrets.freerange = {
    file = ../../secrets/wireguard/freerange.age;
    mode = "0440";
    owner = "0";
    group = "systemd-network";
  };

  boot.kernelModules = [ "ifb" ];
  boot.extraModprobeConfig = ''
    options ifb numifbs=1
  '';

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
          "mgmt-veth" = {
            useDHCP = true;
            macAddress = "5a:1d:49:77:c9:27";
          };
        };
        firewall = {
          enable = true;
          allowPing = true;
          extraCommands = ''
            ip46tables -F FORWARD
            ip46tables -A FORWARD -j DROP
            iptables -I FORWARD 1 -o lte -d 192.168.88.1 -j ACCEPT
            iptables -I FORWARD 2 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
          '';
          extraStopCommands = ''
          '';
        };
        nat = {
          enable = false;
          externalInterface = "lte-veth";
          internalInterfaces = [ "mgmt-veth" ];
          internalIPs = [ ];
        };
        inherit (config.networking) hosts;
      };
      systemd.network = {
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
            lcp-echo-failure 5
            lcp-echo-interval 1
            maxfail 0
            mtu 1492
            mru 1492
            plugin rp-pppoe.so
            name telekom
            user 0024489473715511349841040001@t-online.de
            telekom
            debug
          '';
        };
      };
      systemd.services."pppd-telekom".serviceConfig = lib.mkForce {
        ExecStart = "${lib.getBin pkgs.ppp}/sbin/pppd call telekom nodetach nolog";
        Restart = "always";
        RestartSec = 5;

        # AmbientCapabilities = "CAP_SYS_TTY_CONFIG CAP_NET_ADMIN CAP_NET_RAW CAP_SYS_ADMIN";
        # CapabilityBoundingSet = "CAP_SYS_TTY_CONFIG CAP_NET_ADMIN CAP_NET_RAW CAP_SYS_ADMIN";
        # KeyringMode = "private";
        # LockPersonality = true;
        # MemoryDenyWriteExecute = true;
        # NoNewPrivileges = true;
        # PrivateMounts = true;
        # PrivateTmp = true;
        # ProtectControlGroups = true;
        # ProtectHome = true;
        # ProtectHostname = true;
        # ProtectKernelModules = true;
        # # pppd can be configured to tweak kernel settings.
        # ProtectKernelTunables = false;
        # ProtectSystem = "strict";
        # RemoveIPC = true;
        # RestrictAddressFamilies = "AF_PACKET AF_UNIX AF_PPPOX AF_ATMPVC AF_ATMSVC AF_INET AF_INET6 AF_IPX";
        # RestrictNamespaces = true;
        # RestrictRealtime = true;
        # RestrictSUIDSGID = true;
        # SecureBits = "no-setuid-fixup-locked noroot-locked";
        # SystemCallFilter = "@system-service";
        # SystemCallArchitectures = "native";

        # All pppd instances on a system must share a runtime
        # directory in order for PPP multilink to work correctly. So
        # we give all instances the same /run/pppd directory to store
        # things in.
        #
        # For the same reason, we can't set PrivateUsers=true, because
        # all instances need to run as the same user to access the
        # multilink database.
        RuntimeDirectory = "pppd";
        RuntimeDirectoryPreserve = true;
      };
      environment.etc = {
        "ppp/ip-up" = {
          text = ''
            #!${pkgs.runtimeShell}
            ${pkgs.iproute2}/bin/ip route add default via "$5" dev "${ppp_interface}" metric 512
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
      ${pkgs.iproute2}/bin/ip link add dev upstream-mgmt type veth peer name mgmt-veth

      ${pkgs.iproute2}/bin/ip link set telekom netns wg_upstream
      ${pkgs.iproute2}/bin/ip link set mgmt-veth netns wg_upstream
    '';
    postStopScript = ''
      ${pkgs.iproute2}/bin/ip netns exec wg_upstream ip link set telekom netns 1 || true
      ${pkgs.iproute2}/bin/ip link del upstream-mgmt || true
      ${pkgs.iproute2}/bin/ip link del upstream-lte || true
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
        devpath="%i";
      };
      script =''
        ${pkgs.iproute2}/bin/ip link set dev "$(${pkgs.coreutils}/bin/basename "$devpath")" netns wg_upstream
      '';
    };
    "upstream-container" = {
      after = [ "sys-subsystem-net-devices-mgmt.device" ];
    };
    "lte-dhcp-if" = {
      requires = [ "netns@lte.service" "network.target" ];
      after = [ "netns@lte.service" "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      preStart = ''
        ${pkgs.iproute2}/bin/ip link add dev ltens type veth peer name lte
        ${pkgs.iproute2}/bin/ip link set ltens up
      '';
      script = ''
        ${pkgs.iproute2}/bin/ip link set lte netns lte
        ${pkgs.iproute2}/bin/ip link set ifb0 netns lte

        ${pkgs.iproute2}/bin/ip netns exec lte ${pkgs.iproute2}/bin/ip link set dev lte up
        ${pkgs.iproute2}/bin/ip netns exec lte ${pkgs.iproute2}/bin/ip link set dev lte mtu 1480
        ${pkgs.iproute2}/bin/ip netns exec lte ${pkgs.iproute2}/bin/ip link set dev ifb0 up

        ${pkgs.iproute2}/bin/ip netns exec lte ${pkgs.iproute2}/bin/tc qdisc add dev ifb0 root tbf rate 6500kbit burst 100kb latency 50ms
        ${pkgs.iproute2}/bin/ip netns exec lte ${pkgs.iproute2}/bin/tc qdisc add dev lte handle ffff: ingress
        ${pkgs.iproute2}/bin/ip netns exec lte ${pkgs.iproute2}/bin/tc filter add dev lte parent ffff: protocol all u32 match u32 0 0 action mirred egress redirect dev ifb0
      '';
      postStop = ''
        ${pkgs.iproute2}/bin/ip netns exec lte ${pkgs.iproute2}/bin/tc filter del dev lte root
        ${pkgs.iproute2}/bin/ip netns exec lte ${pkgs.iproute2}/bin/tc qdisc del dev lte ingress
        ${pkgs.iproute2}/bin/ip netns exec lte ${pkgs.iproute2}/bin/tc qdisc del dev ifb0 root
        ${pkgs.iproute2}/bin/ip link del ltens || true
      '';
    };
    "lte-dhcp" = let
      script = pkgs.writeShellScript "udhcpc-dispatch" ''
        case $1 in
          bound|renew)
            ${pkgs.iproute2}/bin/ip addr add dev "$interface" "$ip"/"$subnet"
            ${pkgs.iproute2}/bin/ip route replace 0.0.0.0/0 dev "$interface" via "$router"
            ;;
          deconfig)
            ${pkgs.iproute2}/bin/ip -4 addr flush dev $interface
            ${pkgs.iproute2}/bin/ip -4 route flush dev $interface
            ;;
          leasefail|nak)
            echo "$0: Could not obtain DHCP lease" >&2
            exit 1
            ;;
          *)
            echo "$0: Unknown udhcpc command: $1" >&2
            exit 1
            ;;
        esac
      '';
    in {
      wantedBy = [ "multi-user.target" ];
      requires = [ "lte-dhcp-if.service" ];
      after = [ "lte-dhcp-if.service" ];
      unitConfig = {
        JoinsNamespaceOf = "netns@lte.service";
      };
      serviceConfig = {
        RuntimeDirectory = "lte-dhcp";
        Restart = "always";
        PrivateNetwork = true;
      };
      script = "exec ${pkgs.busybox}/bin/udhcpc -f --interface=lte --script=${script}";
    };
    "wireguard-lanthanum-lte" = {
      after = [ "netns@lte.service" ];
      bindsTo = [ "netns@lte.service" ];
    };
    "wireguard-cerium-lte" = {
      after = [ "netns@lte.service" ];
      bindsTo = [ "netns@lte.service" ];
    };
  };

  networking.wireguard.interfaces."lanthanum-lte".socketNamespace = lib.mkForce "lte";
  networking.wireguard.interfaces."cerium-lte".socketNamespace = lib.mkForce "lte";

  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        valid-lifetime = 600;
        calculate-tee-times = true;
        interfaces-config = {
          interfaces = [
            "auenheim" "ilo" "apc" "forstheim" "celluloid"
          ];
        };
        lease-database = {
          type = "memfile";
          persist = true;
          name = "/var/lib/kea/dhcp4.leases";
        };
        loggers = [
          { name = "kea-dhcp4";
            output_options = [
              { output = "stdout"; }
            ];
            severity = "INFO";
          }
        ];
        option-def = [
          { name = "conf-file";
            code = 209;
            type = "string";
          }
        ];
        client-classes = [
          { name = "actinium-ipxe";
            test = "option[77].hex == 'iPXE' and pkt4.mac == 0x5065f3f0aa00";
            next-server = "10.172.100.1";
            boot-file-name = "actinium/netboot.ipxe";
          }
          { name = "boot-ipxe";
            option-data = [
              { name = "tftp-server-name";
                data = "10.172.100.1";
              }
              { name = "boot-file-name";
                data = "ipxe";
              }
            ];
          }
        ];
        dhcp-ddns = {
          enable-updates = true;
          server-ip = "127.0.0.3";
          server-port = 53001;
          ncr-protocol = "UDP";
          ncr-format = "JSON";
        };
        ddns-send-updates = false;
        ddns-override-client-update = true;
        ddns-override-no-update = true;
        ddns-replace-client-name = "always";
        ddns-generated-prefix = "noname";
        ddns-update-on-renew = true;
        subnet4 = [
          { subnet = "10.172.100.0/24";
            interface = "auenheim";
            ddns-qualifying-suffix = "auenheim.kleen.org";
            ddns-send-updates = true;
            option-data = [
              { name = "domain-name-servers";
                data = "10.172.100.1";
              }
              { name = "routers";
                data = "10.172.100.1";
              }
              { name = "domain-name";
                data = "auenheim.kleen.org";
              }
            ];
            pools = [
              { pool = "10.172.100.102 - 10.172.100.200"; }
            ];
            reservations = [
              { hw-address = "60:f2:62:17:59:7b";
                ip-address = "10.172.100.101";
                hostname = "bohrium";
              }
              { hw-address = "e0:63:da:39:22:9f";
                ip-address = "10.172.100.5";
                hostname = "helium";
              }
              { hw-address = "ac:89:95:f8:15:a3";
                ip-address = "10.172.100.20";
                hostname = "dptrp1";
              }
              { hw-address = "2c:09:4d:00:02:af";
                ip-address = "10.172.100.21";
                hostname = "chlorine-bmc";
              }
              {
                hw-address = "2c:09:4d:00:02:b0";
                ip-address = "10.172.100.23";
                hostname = "chlorine";
              }
              { hw-address = "2c:09:4d:00:02:ae";
                ip-address = "10.172.100.22";
                hostname = "chlorine-boot";
                option-data = [
                  { name = "conf-file";
                    data = "http://boron.auenheim.kleen.org/chlorine/pxelinux.cfg";
                  }
                ];
              }
              { hw-address = "50:65:f3:f0:aa:00";
                client-classes = [ "boot-ipxe" ];
              }
            ];
          }
          { subnet = "10.172.31.0/24";
            interface = "apc";
            ddns-send-updates = false;
            pools = [
              { pool = "10.172.31.100 - 10.172.31.200"; }
            ];
            reservations = [
              { hw-address = "00:c0:b7:4a:a6:18";
                ip-address = "10.172.31.2";
                hostname = "auenheim-ats";
              }
            ];
          }
          { subnet = "10.172.32.0/24";
            interface = "ilo";
            ddns-send-updates = false;
            pools = [
              { pool = "10.172.32.100 - 10.172.32.200"; }
            ];
          }
          { subnet = "10.172.12.0/24";
            interface = "forstheim";
            ddns-qualifying-suffix = "forstheim.kleen.org";
            ddns-send-updates = true;
            pools = [
              { pool = "10.172.12.100 - 10.172.12.200"; }
            ];
            reservations = [
              { hw-address = "a8:93:4a:67:7c:c1";
                ip-address = "10.172.12.2";
                hostname = "forst";
              }
            ];
          }
          { subnet = "10.172.13.0/24";
            interface = "celluloid";
            ddns-qualifying-suffix = "celluloid.kleen.org";
            ddns-send-updates = true;
            pools = [
              { pool = "10.173.13.100 - 10.172.13.200"; }
            ];
          }
        ];
      };
    };
    dhcp-ddns = {
      enable = true;
      settings = {
        ip-address = "127.0.0.3";
        port = 53001;
        dns-server-timeout = 100;
        ncr-protocol = "UDP";
        ncr-format = "JSON";
        loggers = [
          { name = "kea-dhcp-ddns";
            output_options = [
              { output = "stdout"; }
            ];
            severity = "INFO";
          }
        ];
        forward-ddns = {
          ddns-domains = [
            { name = "auenheim.kleen.org.";
              dns-servers = [
                { ip-address = "127.0.0.2";
                  port = 53;
                  key-name = "dhcp-tsig";
                }
              ];
            }
            { name = "forstheim.kleen.org.";
              dns-servers = [
                { ip-address = "127.0.0.2";
                  port = 53;
                  key-name = "dhcp-tsig";
                }
              ];
            }
            { name = "celluloid.kleen.org.";
              dns-servers = [
                { ip-address = "127.0.0.2";
                  port = 53;
                  key-name = "dhcp-tsig";
                }
              ];
            }
          ];
        };
        reverse-ddns = {
          ddns-domains = [
            { name = "100.172.10.in-addr.arpa.";
              dns-servers = [
                { ip-address = "127.0.0.2";
                  port = 53;
                  key-name = "dhcp-tsig";
                }
              ];
            }
            { name = "12.172.10.in-addr.arpa.";
              dns-servers = [
                { ip-address = "127.0.0.2";
                  port = 53;
                  key-name = "dhcp-tsig";
                }
              ];
            }
            { name = "13.172.10.in-addr.arpa.";
              dns-servers = [
                { ip-address = "127.0.0.2";
                  port = 53;
                  key-name = "dhcp-tsig";
                }
              ];
            }
          ];
        };
      };
    };
  };
  systemd.services.kea-dhcp-ddns-server.serviceConfig = let 
    configLines = [
      "<?include \"@CREDENTIALS_DIRECTORY@/knot-boron-tsig\"?>"
    ] ++ lib.mapAttrsToList (k: v:
      "\"${k}\": ${builtins.toJSON v}"
    ) config.services.kea.dhcp-ddns.settings;

    config-template = pkgs.writeText "dhcp-ddns.conf" ''
      {"DhcpDdns": {
        ${lib.concatStringsSep ",\n" configLines}
      }}
    '';
  in {
    ExecStartPre = pkgs.writeShellScript "kea-dhcp-ddns-server-startpre" ''
      ${pkgs.gnused}/bin/sed -e s";@CREDENTIALS_DIRECTORY@;$CREDENTIALS_DIRECTORY;g" "${config-template}" > "$RUNTIME_DIRECTORY/dhcp-ddns.conf"
    '';
    ExecStart = lib.mkForce ''
      ${pkgs.kea}/bin/kea-dhcp-ddns -c "''${RUNTIME_DIRECTORY}/dhcp-ddns.conf" ${lib.escapeShellArgs config.services.kea.dhcp-ddns.extraArgs}
    '';
    LoadCredential = [
      "knot-boron-tsig:/run/agenix/kea-boron-tsig"
    ];
  };

  age.secrets."kea-boron-tsig" = {
    file = ../../secrets/kea-boron-tsig.age;
    owner = "root";
  };

  services.atftpd = {
    enable = false;
    root = "/srv/tftp";
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

  systemd.network = {
    networks."40-eth0" = {
      networkConfig = {
        LinkLocalAddressing = "no";
        LLDP = "yes";
        EmitLLDP = "yes";
      };
    };
    networks."40-forstheim" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
    networks."40-celluloid" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
    networks."40-auenheim-mgmt" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
    networks."40-zte" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
    networks."40-lte-bridge" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
      dhcpV4Config = {
        UseRoutes = "no";
      };
    };
    networks."40-upstream-mgmt" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
    networks."40-upstream-lte" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
    networks."40-wg-europium" = {
      linkConfig = {
        MTUBytes = "1320";
      };
    };
    networks."40-neodymium" = {
      linkConfig = {
        MTUBytes = "1320";
      };
    };
    #networks."40-freerange" = {
    #  linkConfig = {
    #    MTUBytes = "1320";
    #  };
    #};
  };

  services.resolved = {
    enable = false;
  };

  services.unbound = {
    enable = true;
    localControlSocketPath = "/var/lib/unbound/control.socket";
    settings = {
      server = {
        interface = [ "127.0.0.1" "10.172.100.1" "::1" "2a06:e881:9008::1" ];
        prefer-ip6 = true;
        access-control = [ "10.172.100.0/24 allow" "127.0.0.0/24 allow" "::1/128 allow" "2a06:e881:9008::/64 allow" ];
        local-zone = ["100.172.10.in-addr.arpa. transparent"];
        domain-insecure = "100.172.10.in-addr.arpa.";
        do-not-query-localhost = "no";
      };
      stub-zone = [
        {
          name = "auenheim.kleen.org.";
          stub-addr = "127.0.0.2";
          stub-first = true;
          stub-no-cache = true;
          stub-prime = false;
        }
        {
          name = "forstheim.kleen.org.";
          stub-addr = "127.0.0.2";
          stub-first = true;
          stub-no-cache = true;
          stub-prime = false;
        }
        {
          name = "celluloid.kleen.org.";
          stub-addr = "127.0.0.2";
          stub-first = true;
          stub-no-cache = true;
          stub-prime = false;
        }
        {
          name = "100.172.10.in-addr.arpa.";
          stub-addr = "127.0.0.2";
          stub-first = true;
          stub-no-cache = true;
          stub-prime = false;
        }
        {
          name = "12.172.10.in-addr.arpa.";
          stub-addr = "127.0.0.2";
          stub-first = true;
          stub-no-cache = true;
          stub-prime = false;
        }
        {
          name = "13.172.10.in-addr.arpa.";
          stub-addr = "127.0.0.2";
          stub-first = true;
          stub-no-cache = true;
          stub-prime = false;
        }
      ];
    };
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
        - id: ed25519
          algorithm: ed25519
          rrsig-lifetime: 25h
          rrsig-refresh: 20h
      mod-onlinesign:
        - id: explicit
          policy: ed25519
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
          module: [mod-synthrecord/ip4-forward, mod-synthrecord/ip6-forward, mod-onlinesign/explicit]
          zonefile-sync: -1
          zonefile-load: none
          journal-content: all
          acl: update_acl
        - domain: forstheim.kleen.org
          storage: /var/lib/knot/zones
          module: [mod-onlinesign/explicit]
          zonefile-sync: -1
          zonefile-load: none
          journal-content: all
          acl: update_acl
        - domain: celluloid.kleen.org
          storage: /var/lib/knot/zones
          module: [mod-onlinesign/explicit]
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
        - domain: 12.172.10.in-addr.arpa
          storage: /var/lib/knot/zones
          dnssec-signing: off
          zonefile-sync: -1
          zonefile-load: none
          journal-content: all
          acl: update_acl
        - domain: 13.172.10.in-addr.arpa
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
