{ flake, config, hostName, lib, pkgs, ... }:
with (import ./utils.nix { inherit lib flake; });
let
  inherit (config.networking.wolkenheim) fabric;
  localASN = hostASN fabric hostName;
  localAS = hostAS fabric hostName;
  normalizedLinks = normalize fabric.wg-links;

  name = linkName hostName;
  remote = linkRemote hostName;
in {
  imports = [ ./gobgp.nix ./bgp-uplink.nix ];
  config = lib.mkMerge [
    {
      environment.systemPackages = [
        pkgs.frr
      ];
      environment.etc = {
        "frr/zebra.conf".text = ''
          hostname ${hostName}
          log syslog
          service password-encryption
          ip nht resolve-via-default
        '';
        "frr/vtysh.conf".text = "";
      };
      users.users.frr = {
        description = "FRR daemon user";
        isSystemUser = true;
        group = "frr";
      };
      users.groups = {
        frr = {};
        frrvty = { members = [ "frr" ]; };
      };
      systemd.services.zebra = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "systemd-sysctl.service" ];

        description = "FRR Zebra routing manager";

        unitConfig.Documentation = "man:zebra(8)";

        serviceConfig = {
          PIDFile = "frr/zebra.pid";
          ExecStart = "${pkgs.frr}/libexec/frr/zebra -f /etc/frr/zebra.conf --vty_addr localhost --vty_port 0";
          Restart = "always";
          User = "frr";
          Group = "frr";
          SupplementaryGroups = [ "frrvty" ];
          RuntimeDirectoryMode = "0700";
          RuntimeDirectory = "frr";
          LogsDirectory = "frr";
          AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
          CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
        };
      };

      systemd.services.gobgpd = {
        after = [ "zebra.service" ];
        bindsTo = [ "zebra.service" ];
        serviceConfig = {
          DynamicUser = false;
          User = "frr";
          Group = "frr";
        };
      };

      networking.gobgpd.enable = true;
      networking.gobgpd.config = {
        global = {
          config = {
            as = localASN;
            router-id = private_address fabric.ip4NamespaceAllocation.reserved_router_id hostIds.${hostName};
            port = lib.mkDefault (-1);
          };
          apply-policy.config = {
            default-import-policy = "reject-route";
            default-export-policy = "reject-route";
          };
        };
        zebra.config = {
          enabled = true;
          url = "unix:///run/frr/zserv.api";
          redistribute-route-type-list = lib.mkDefault [];
          version = 6;
        };
        peer-groups = lib.attrsets.mapAttrsToList
          (n: as: {
            config = {
              peer-group-name = n;
              peer-as = ASN n;
            };
            timers.config = {
              hold-time = 15;
              keepalive-interval = 5;
            };
            afi-safis = [
              { config.afi-safi-name = "ipv4-unicast"; }
              { config.afi-safi-name = "ipv6-unicast"; }
            ];
          })
          (otherAS fabric hostName);
        neighbors = lib.lists.map
          (l: {
            config = {
              neighbor-interface = name l;
              peer-group = fabric.hosts.${(remote l).host}.AS;
            };
            transport.config.passive-mode = true;
          })
          (linksInvolving hostName normalizedLinks);
        defined-sets.neighbor-sets = lib.lists.map
          (l: {
            neighbor-set-name = name l;
            neighbor-info-list = [ (private_address6 l.linkId hostIds.${(remote l).host}) ];
          })
          (linksInvolving hostName normalizedLinks);
      };
    }
    (lib.mkIf (localAS.announcePublic or false) {
      environment.etc = {
        "frr/staticd.conf".text = with localAS; ''
          ip route ${public4} blackhole 254
          ipv6 route ${public6} blackhole 254
        '';
      };

      systemd.services.staticd = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "systemd-sysctl.service" "zebra.service" ];
        bindsTo = [ "zebra.service" ];

        description = "FRR STATIC routing daemon";

        unitConfig.Documentation = "man:staticd(8) man:zebra(8)";

        serviceConfig = {
          PIDFile = "frr/staticd.pid";
          ExecStart = "${pkgs.frr}/libexec/frr/staticd -f /etc/frr/staticd.conf --vty_addr localhost --vty_port 0";
          Restart = "always";
          User = "frr";
          Group = "frr";
          SupplementaryGroups = [ "frrvty" ];
          LogsDirectory = "frr";
          AmbientCapabilities = [ ];
          CapabilityBoundingSet = [ ];
        };
      };

      networking.gobgpd.config.zebra.config.redistribute-route-type-list = [ "static" "directly-connected" ];

      systemd.network = {
        netdevs."40-public" = {
          netdevConfig = {
            Name = "public";
            Kind = "dummy";
          };
          extraConfig = ''
            [Match]
          '';
        };
        networks."40-public" = {
          name = "public";
          address = with localAS; [
            public4 public6
          ];
          networkConfig = {
            LinkLocalAddressing = "no";
          };
        };
      };
    })
  ];
}
