{ config, flake, pkgs, lib, ... }:
let
  ppp_interface = "wan";

  inherit (flake.inputs.utils.lib) private_address private_address6;
  machine_id = config.environment.etc."machine-id".text;

  bfdConfig = (pkgs.formats.yaml {}).generate "bfdd.yaml" {
    listen = [ "${private_address 64 config.environment.etc."machine-id".text}" ];
    peers = {
      "${private_address 64 flake.nixosConfigurations.lanthanum.config.environment.etc."machine-id".text}" = {
        name = "lanthanum";
        port = 3784;
        interval = 250;
        detectionMultiplier = 2;
      };
    };
  };
in {
  environment.systemPackages = [
    pkgs.bfd
  ];

  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
    nameserver ::1
    search auenheim.kleen.org
  '';
  system.publicAddresses = [
    "2a01:7e01:e002:aa02::1"
  ];
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
      "apc" = {
        id = 31;
        interface = "eth0";
      };
      "ilo" = {
        id = 32;
        interface = "eth0";
      };
      "lte" = {
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
          { address = "2a01:7e01:e002:aa02::1"; prefixLength = 64; }
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
    };

    bridges = {
      "mgmt" = {
        interfaces = [ "auenheim-mgmt" "upstream-mgmt" ];
      };
    };

    nat = {
      enable = true;
      externalInterface = "wg-europium";
      internalInterfaces = [ "auenheim" ];
    };

    firewall = {
      enable = true;
      allowPing = true;
      interfaces = {
        "auenheim" = {
          allowedUDPPorts = [ 53 69 ];
          allowedTCPPorts = [ 53 69 8883 ];
        };
        "lanthanum" = {
          allowedUDPPorts = [ 3784 ];
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
      "45.32.153.151" =  [ "lanthanum.kleen.org" ];
      "45.32.154.225" =  [ "cerium.kleen.org" ];
    };

    wireguard.interfaces = {
      wg-europium = {
        ips = [ "10.172.40.136/24" "2a01:7e01:e002:aa00:cc6b:36a1:0:1/64" ];
        privateKeyFile = "/run/agenix/boron";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../../wireguard/europium.pub;
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
  age.secrets.boron = {
    file = ../../secrets/wireguard/boron.age;
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
          "lte" = {
            useDHCP = true;
          };
          "ifb0" = {
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

            ${pkgs.iproute}/bin/tc qdisc add dev ifb0 root tbf rate 5000kbit burst 5kb latency 100ms
            ${pkgs.iproute}/bin/tc qdisc add dev lte handle ffff: ingress
            ${pkgs.iproute}/bin/tc filter add dev lte parent ffff: protocol all u32 match u32 0 0 action mirred egress redirect dev ifb0
          '';
          extraStopCommands = ''
            ${pkgs.iproute}/bin/tc filter del dev lte root
            ${pkgs.iproute}/bin/tc qdisc del dev lte ingress
            ${pkgs.iproute}/bin/tc qdisc del dev ifb0 root
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
            RouteMetric = 2048;
          };
          networkConfig = {
            DHCP = lib.mkForce "ipv4";
            LinkLocalAddressing = "no";
          };
          routes = [
            { routeConfig = {
                Destination = "94.16.123.211/32";
                Gateway = "192.168.88.1";
              };
            }
          ];
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
      systemd.services."lte-keepalive" = {
        requires = [ "systemd-networkd-wait-online.service" ];
        wantedBy = [ "network-online.target" ];
        serviceConfig = {
          ExecStart = "${config.security.wrapperDir}/ping -i10 94.16.123.211";
          Restart = "always";
          RestartSec = 10;
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
      ${pkgs.iproute}/bin/ip link add dev upstream-mgmt type veth peer name mgmt-veth

      ${pkgs.iproute}/bin/ip link set telekom netns wg_upstream
      ${pkgs.iproute}/bin/ip link set mgmt-veth netns wg_upstream
      ${pkgs.iproute}/bin/ip link set ifb0 netns wg_upstream
      ${pkgs.iproute}/bin/ip link set lte netns wg_upstream
    '';
    postStopScript = ''
      ${pkgs.iproute}/bin/ip netns exec wg_upstream ip link set telekom netns 1 || true
      ${pkgs.iproute}/bin/ip netns exec wg_upstream ip link set ifb0 netns 1 || true
      ${pkgs.iproute}/bin/ip netns exec wg_upstream ip link set lte netns 1 || true
      ${pkgs.iproute}/bin/ip link del upstream-mgmt || true
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
    "upstream-container" = {
      after = [ "sys-subsystem-net-devices-mgmt.device" ];
    };
  };

  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        valid-lifetime = 600;
        calculate-tee-times = true;
        interfaces-config = {
          interfaces = [
            "auenheim" "ilo" "apc"
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
        ddns-qualifying-suffix = "auenheim.kleen.org";
        ddns-update-on-renew = true;
        subnet4 = [
          { subnet = "10.172.100.0/24";
            interface = "auenheim";
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
                    data = "tftp://boron.auenheim.kleen.org/chlorine/pxelinux.cfg";
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
    enable = true;
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
  };

  services.resolved = {
    enable = false;
  };

  services.unbound = {
    enable = true;
    localControlSocketPath = "/var/lib/unbound/control.socket";
    settings = {
      server = {
        interface = [ "127.0.0.1" "10.172.100.1" "::1" "2a01:7e01:e002:aa02::1" ];
        access-control = [ "10.172.100.0/24 allow" "127.0.0.0/24 allow" "::1/128 allow" ];
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
          name = "100.172.10.in-addr.arpa.";
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

  systemd.services.bfdd = {
    #wantedBy = [ "multi-user.target" ];
    #after = [ "network.target" "wireguard-lanthanum.service" ];
    #requires = [ "wireguard-lanthanum.service" ];
    script = ''
      exec ${pkgs.bfdd}/bin/bfdd -c "${bfdConfig}"
    '';
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
    };
  };
}
