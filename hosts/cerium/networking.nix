{ config, pkgs, lib, flake, ... }:
let
  inherit (builtins) substring;
  inherit (flake.inputs.utils.lib) private_address;
  machine_id = config.environment.etc."machine-id".text;

  nft_ruleset = let
    tcpPorts =
         lib.lists.map builtins.toString config.networking.firewall.allowedTCPPorts
      ++ lib.lists.map ({from,to}: "${builtins.toString from}-${builtins.toString to}") config.networking.firewall.allowedTCPPortRanges;
    udpPorts =
         lib.lists.map builtins.toString config.networking.firewall.allowedUDPPorts
      ++ lib.lists.map ({from,to}: "${builtins.toString from}-${builtins.toString to}") config.networking.firewall.allowedUDPPortRanges;
  in ''
    define icmp_protos = { ipv6-icmp, icmp, igmp }
    define udp_allowed_ports = { ${lib.strings.concatStringsSep "," udpPorts} }
    define tcp_allowed_ports = { ${lib.strings.concatStringsSep "," tcpPorts} }

    define trusted_interfaces = { lo, ${lib.strings.concatStringsSep "," config.networking.firewall.trustedInterfaces} }

    table inet filter {
      chain input {
        type filter hook input priority filter
        policy drop

        iifname $trusted_interfaces accept
        ct state { related, established } accept

        meta l4proto ipv6-icmp icmpv6 type nd-redirect drop

        meta l4proto $icmp_protos accept
        meta l4proto tcp tcp dport $tcp_allowed_ports accept
        meta l4proto udp udp dport $udp_allowed_ports accept
      }

      chain forward {
        type filter hook forward priority filter
        policy drop

        oifname { boron-dsl, boron-lte } accept
        iifname { boron-dsl, boron-lte } accept
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
  '';

in {
  system.publicAddresses = [
    "45.32.154.225"
    "2001:19f0:6c01:284a:5400:03ff:fec6:c9b0"
  ];
  
  environment.systemPackages = [
    pkgs.nftables
  ];

  networking = {
    useDHCP = false;
    useNetworkd = true;
    nameservers = [
      "2001:19f0:300:1704::6"
    ];
    interfaces = {
      "enp1s0" = {
        useDHCP = true;
        ipv4.addresses = [ {
          address = "45.32.154.225";
          prefixLength = 22;
        } ];
        ipv6.addresses = [ {
          address = "2001:19f0:6c01:284a:5400:03ff:fec6:c9b0";
          prefixLength = 64;
        } ];
      };
      "enp6s0" = {
        ipv4.addresses = [ {
          address = private_address 32 machine_id;
          prefixLength = 16;
        } ];
        mtu = 1450;
      };
    };
    firewall = {
      enable = false;
      trustedInterfaces = [ "enp6s0" "boron-dsl" "boron-lte" ];
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
    nftables = {
      enable = true;
      ruleset = nft_ruleset;
    };
    wireguard.interfaces = {
      europium = {
        ips = [ "10.172.41.100/24" ];
        privateKeyFile = "/run/agenix/cerium";
        allowedIPsAsRoutes = false;
        peers = [
          { publicKey = builtins.readFile ../../wireguard/europium.pub;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "europium.kleen.org:51821";
            persistentKeepalive = 1;
          }
        ];
      };
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 2;
  };
  systemd.network = {
    networks."40-enp1s0" = {
      routes = [
        { routeConfig = {
            Destination = "2001:19f0:ffff::1/128";
            PreferredSource = "2001:19f0:6c01:21c1:5400:03ff:fec6:c9cd";
            Gateway = "_ipv6ra";
          };
        }
        { routeConfig = {
            Destination = "169.254.169.254";
            PreferredSource = "45.32.154.225";
            Gateway = "_dhcp4";
          };
        }
      ];
      ipv6AcceptRAConfig = {
        UseAutonomousPrefix = "no";
        UseOnLinkPrefix = "no";
      };
    };
    networks."40-enp6s0" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
  };
}
