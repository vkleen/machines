{ config, pkgs, ... }:
{
  imports = [
    ./kresd.nix
  ];

  services.ndppd = {
    enable = true;
    configFile = pkgs.writeText "ndppd.conf" ''
      route-ttl 30000
      proxy ens3 {
        router yes
        timeout 5000
        ttl 30000
        rule 2a03:4000:21:6c9:ba9c::/80 {
          static
        };
      };
    '';
  };

  networking = {
    hostName = "samarium";
    useDHCP = false;
    defaultGateway = {
      address = "94.16.120.1";
      interface = "ens3";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
    interfaces = {
      "ens3".ipv4.addresses = [ {
        address = "94.16.123.211";
        prefixLength = 22;
      } ];
      "ens3".ipv6.addresses = [ {
        address = "2a03:4000:21:6c9::1";
        prefixLength = 64;
      } ];
    };
    firewall = {
      enable = true;
      trustedInterfaces = [ "wg0" ];
      allowPing = true;
      allowedTCPPorts = [ 25 80 443 2022 ];
      allowedUDPPorts = [ 51820 ];
      allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

      extraCommands = ''
        iptables -I nixos-fw -d 94.16.123.211 -p tcp -m tcp --dport 8443 -j DROP
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
        iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE
      '';
      extraStopCommands = ''
        ip46tables -D FORWARD -j nixos-fw-forward 2>/dev/null || true
        ip46tables -F nixos-fw-forward 2> /dev/null || true
        ip46tables -X nixos-fw-forward 2> /dev/null || true
      '';
    };

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.172.20.1/24" "2a03:4000:21:6c9:ba9c:c4de:cb69:1/80" ];
        privateKeyFile = "/run/keys/samarium";
        listenPort = 51820;
        peers = [
          { publicKey = builtins.readFile ../wireguard/seaborgium.pub;
            allowedIPs = [ "10.172.20.128/32" "2a03:4000:21:6c9:ba9c:b01a:0a7d::/112" ];
          }
          { publicKey = builtins.readFile ../wireguard/freyr.pub;
            allowedIPs = [ "10.172.20.129/32" "2a03:4000:21:6c9:ba9c:cc8e:b00c::/112" ];
          }
          { publicKey = builtins.readFile ../wireguard/hydrogen.pub;
            allowedIPs = [ "10.172.20.130/32" "2a03:4000:21:6c9:ba9c:a42f:9c97::/112" ];
          }
          { publicKey = builtins.readFile ../wireguard/helium.pub;
            allowedIPs = [ "10.172.20.131/32" "2a03:4000:21:6c9:ba9c:b467:24b8::/112" ];
          }
          { publicKey = builtins.readFile ../wireguard/bohrium.pub;
            allowedIPs = [ "10.172.20.132/32" "2a03:4000:21:6c9:ba9c:2469:eead::/112" ];
          }
        ];
      };
    };
  };

  systemd.services.wstunnel = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "Wireguard over wstunnel";
    serviceConfig = {
      User = "nobody";
      ExecStart = "${pkgs.wstunnel}/bin/wstunnel -u --server ws://127.0.0.1:8080 -r 127.0.0.1:51820";
    };
  };

  systemd.services.udp2rawtunnel = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "Wireguard over udp2raw";
    serviceConfig = {
      User = "nobody";
      ExecStart = "${config.security.wrapperDir}/udp2raw -s -l 94.16.123.211:8443 -r 127.0.0.1:51820 --cipher-mode none --auth-mode none";
    };
  };

  security.wrappers = {
    udp2raw = {
      source = "${pkgs.udp2raw}/bin/udp2raw";
      owner = "nobody";
      group = "nogroup";
      capabilities = "cap_net_raw+ep";
    };
  };

  services.nginx.virtualHosts."${config.mailserver.fqdn}" = {
    locations."/iLTCfCvXrwOuenVWtahGddnNWgGJRBLc/" = {
      proxyPass = "http://127.0.0.1:8080";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Real-IP $remote_addr;
      '';
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 2;
    "net.ipv6.conf.all.proxy_ndp" = 1;
    "net.ipv6.conf.default.proxy_ndp" = 1;
  };
}
