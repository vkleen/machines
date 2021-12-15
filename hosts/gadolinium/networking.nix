{ config, pkgs, ... }:
{
  networking.usePredictableInterfaceNames = false;

  system.publicAddresses = [
    "139.162.135.104"
    "2a01:7e01::f03c:92ff:feb5:5141"
  ];

  networking = {
    hostName = "gadolinium";
    useDHCP = false;
    nameservers = [
      "139.162.130.5" "2a01:7e01::5"
    ];
    defaultGateway = {
      address = "139.162.135.1";
      interface = "eth0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    interfaces = {
      "eth0".ipv4.addresses = [ {
        address = "139.162.135.104";
        prefixLength = 24;
      } ];
      "eth0".ipv6.addresses = [
        {
          address = "2a01:7e01::f03c:92ff:feb5:5141";
          prefixLength = 128;
        }
        {
          address = "fe80::f03c:92ff:feb5:5141";
          prefixLength = 64;
        }
      ];
    };
    firewall = {
      enable = true;
      trustedInterfaces = [ "wg0" ];
      allowPing = true;
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 51820 53 ];

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

        ip6tables -A nixos-fw-forward -p tcp --dport 22  -j ACCEPT

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
      internalIPs = [ "10.172.40.2/24" ];
      externalInterface = "eth0";
      externalIP = "139.162.135.104";
      forwardPorts = [];
    };
    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.172.40.2/24" "2a01:7e01:e002:aa00:0a4b:eded::1/64" ];
        privateKeyFile = "/run/agenix/gadolinium";
        listenPort = 51820;
        peers = [
          { publicKey = builtins.readFile ../../wireguard/bohrium.pub;
            allowedIPs = [ "10.172.40.132/32" "2a01:7e01:e002:aa00:2469:eead::/96" ];
          }
          { publicKey = builtins.readFile ../../wireguard/helium.pub;
            allowedIPs = [ "10.172.40.133/32" "2a01:7e01:e002:aa00:b467:24b8::/96" ];
          }
          { publicKey = builtins.readFile ../../wireguard/boron.pub;
            allowedIPs = [ "10.172.40.136/32" "2a01:7e01:e002:aa00:cc6b:36a1::/96" "2a01:7e01:e002:aa02::/64" ];
          }
        ];
      };
    };
  };
  age.secrets.gadolinium.file = ../../secrets/wireguard/gadolinium.age;
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 2;
  };
}
