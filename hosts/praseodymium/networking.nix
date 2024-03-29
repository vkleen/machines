{ config, pkgs, lib, flake, ... }:
let
  inherit (builtins) substring;
  inherit (flake.inputs.utils.lib) private_address mkV4 mkV6;
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
    (mkV4 "185.101.96.44")
    (mkV6 "2a00:1098:2e:4::1")
  ];
  
  environment.systemPackages = [
    pkgs.nftables
  ];

  networking = {
    useDHCP = false;
    useNetworkd = true;
    nameservers = [
      "8.8.8.8"
      "2001:4860:4860::8844"
    ];
    defaultGateway = {
      address = "185.101.96.1";
    };
    interfaces = {
      "ens3" = {
        useDHCP = false;
        ipv4.addresses = [ {
          address = "185.101.96.44";
          prefixLength = 24;
        } ];
        ipv6.addresses = [ {
          address = "2a00:1098:2e:4::1";
          prefixLength = 64;
        } ];
      };
    };
    firewall = {
      enable = false;
      trustedInterfaces = [];
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
    nftables = {
      enable = true;
      ruleset = nft_ruleset;
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 2;
  };
}
