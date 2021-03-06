{ config, pkgs, ... }:
{
  imports = [
    ./kresd.nix
  ];

  networking.usePredictableInterfaceNames = false;

  networking = {
    hostName = "europium";
    useDHCP = false;
    defaultGateway = {
      address = "172.104.139.1";
      interface = "eth0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    interfaces = {
      "eth0".ipv4.addresses = [ {
        address = "172.104.139.29";
        prefixLength = 24;
      } ];
      "eth0".ipv6.addresses = [
        {
          address = "2a01:7e01:e002:aa00::1";
          prefixLength = 56;
        }
        {
          address = "2a01:7e01::f03c:92ff:fe12:a0f4";
          prefixLength = 128;
        }
        {
          address = "fe80::f03c:92ff:fe12:a0f4";
          prefixLength = 64;
        }
      ];
    };
    firewall = {
      enable = true;
      trustedInterfaces = [ "wg0" ];
      allowPing = true;
      allowedTCPPorts = [ 25 80 443 ];
      allowedUDPPorts = [ 51820 53 ];
      allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

      extraCommands = ''
        ip46tables -D FORWARD -j nixos-fw-forward 2>/dev/null || true
        ip46tables -F nixos-fw-forward 2> /dev/null || true
        ip46tables -X nixos-fw-forward 2> /dev/null || true

        ip46tables -N nixos-fw-forward
        ip46tables -A nixos-fw-forward -i wg0 -j ACCEPT
        ip46tables -A nixos-fw-forward -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

        ip6tables -A nixos-fw-forward -p icmpv6 --icmpv6-type redirect -j DROP
        ip6tables -A nixos-fw-forward -p icmpv6 --icmpv6-type 139 -j DROP
        ip6tables -A nixos-fw-forward -p icmpv6 -j ACCEPT

        ip46tables -A nixos-fw-forward -j DROP
        ip46tables -A FORWARD -j nixos-fw-forward
      '';
      extraStopCommands = ''
        ip46tables -D FORWARD -j nixos-fw-forward 2>/dev/null || true
        ip46tables -F nixos-fw-forward 2> /dev/null || true
        ip46tables -X nixos-fw-forward 2> /dev/null || true
      '';
    };
    nat = {
      enable = true;
      internalInterfaces = [ "wg0" ];
      internalIPs = [ "10.172.30.1/24" ];
      externalInterface = "eth0";
      externalIP = "172.104.139.29";
      forwardPorts = [];
    };
    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.172.40.1/24" "2a01:7e01:e002:aa00:f8a1:f27f::1/64" ];
        privateKeyFile = "/run/keys/europium";
        listenPort = 51820;
        peers = [
          { publicKey = builtins.readFile ../wireguard/einsteinium.pub;
            allowedIPs = [ "10.172.40.131/32" "2a01:7e01:e002:aa00:c456:3f87::/96" ];
          }
          { publicKey = builtins.readFile ../wireguard/bohrium.pub;
            allowedIPs = [ "10.172.40.132/32" "2a01:7e01:e002:aa00:2469:eead::/96" ];
          }
          { publicKey = builtins.readFile ../wireguard/helium.pub;
            allowedIPs = [ "10.172.40.133/32" "2a01:7e01:e002:aa00:b467:24b8::/96" "2a01:7e01:e002:aa01::/64" ];
          }
          { publicKey = builtins.readFile ../wireguard/hydrogen.pub;
            allowedIPs = [ "10.172.40.134/32" "2a01:7e01:e002:aa00:a42f:9c97::/96" ];
          }
          { publicKey = builtins.readFile ../wireguard/chlorine.pub;
            allowedIPs = [ "10.172.40.135/32" "2a01:7e01:e002:aa00:5319:9d00::/96" ];
          }
        ];
        # postSetup = ''
        #   ip link add gre-seaborgium type ip6gretap dev wg0 key 1 \
        #     local 2600:3c01:e002:8b9d:d034:b380::1 \
        #     remote 2600:3c01:e002:8b9d:b01a:0a7d::1

        #   ip link add gre-freyr type ip6gretap dev wg0 key 2 \
        #     local 2600:3c01:e002:8b9d:d034:b380::1 \
        #     remote 2600:3c01:e002:8b9d:cc8e:b00c::1

        #   ip link set gre-seaborgium up
        #   ip link set gre-freyr up
        #   ${pkgs.batctl}/bin/batctl if create
        #   ${pkgs.batctl}/bin/batctl if add gre-seaborgium
        #   ${pkgs.batctl}/bin/batctl if add gre-freyr
        # '';
        # postShutdown = ''
        #   ${pkgs.batctl}/bin/batctl if destroy
        #   ip link delete gre-freyr
        #   ip link delete gre-seaborgium
        # '';
      };
    };
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 2;
  };
}
