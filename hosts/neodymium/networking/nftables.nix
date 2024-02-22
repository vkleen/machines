{ config, lib, ... }:
let
  nft_ruleset =
    let
      globalTcpPorts =
        lib.lists.map builtins.toString config.networking.firewall.allowedTCPPorts
        ++ lib.lists.map ({ from, to }: "${builtins.toString from}-${builtins.toString to}") config.networking.firewall.allowedTCPPortRanges;
      globalUdpPorts =
        lib.lists.map builtins.toString config.networking.firewall.allowedUDPPorts
        ++ lib.lists.map ({ from, to }: "${builtins.toString from}-${builtins.toString to}") config.networking.firewall.allowedUDPPortRanges;

      interfaceTcpPorts = i: lib.lists.map builtins.toString config.networking.firewall.interfaces.${i}.allowedTCPPorts;
      interfaceUdpPorts = i: lib.lists.map builtins.toString config.networking.firewall.interfaces.${i}.allowedUDPPorts;
    in
    ''
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
          iifname { boron } accept
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
      table ip nat {
        chain prerouting {
          type nat hook prerouting priority dstnat
          policy accept

          iifname { boron } meta mark set 0x1
        }
        chain postrouting {
          type nat hook postrouting priority srcnat
          policy accept

          oifname { ens3 } mark 0x1 masquerade
        }
      }
    '';
in
{
  networking = {
    nftables = {
      enable = true;
      ruleset = nft_ruleset;
    };
    firewall = {
      enable = false;
      allowPing = true;
      allowedTCPPorts = [ 25 80 443 6969 ];
      allowedUDPPorts = [ 51820 51821 51822 53 123 ];
    };
  };
}
