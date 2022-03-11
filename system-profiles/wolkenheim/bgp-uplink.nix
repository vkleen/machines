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
  config = lib.mkIf (fabric.uplinks.${hostName}.type or "" == "bgp") {
    environment.etc = {
      "frr/staticd.conf".text = with localAS; ''
        ip route 206.83.40.91/32 45.32.152.1
      '';
    };
    networking.gobgpd.credentialFile = fabric.uplinks.${hostName}.credentials;
    networking.gobgpd.config = {
      global = {
        config = {
          port = 179;
        };
        apply-policy.config = {
          import-policy-list = [ "uplink-routes" "routes-import" ];
          export-policy-list = [
            "export-next-hop" "uplink-routes" "routes-export"
          ];
        };
      };
      zebra.config.redistribute-route-type-list = [ "kernel" "static" ];
      peer-groups = [
        ({ config = {
             peer-group-name = "uplink";
             peer-as = fabric.uplinks.${hostName}.remote-as;
             local-as = fabric.uplinks.${hostName}.local-as;
             auth-password = fabric.uplinks.${hostName}.password;
           };
           timers.config = {
             hold-time = 3;
             keepalive-interval = 1;
           };
         } // fabric.uplinks.${hostName}.extraGobgpNeighborConfig)
      ];
      neighbors = [
        { config = {
            neighbor-address = fabric.uplinks.${hostName}.peer4;
            peer-group = "uplink";
            remove-private-as = "all";
          };
          afi-safis = [
            { config.afi-safi-name = "ipv4-unicast"; }
          ];
        }
        { config = {
            neighbor-address = fabric.uplinks.${hostName}.peer6;
            peer-group = "uplink";
            remove-private-as = "all";
          };
          afi-safis = [
            { config.afi-safi-name = "ipv6-unicast"; }
          ];
        }
      ];
      defined-sets.prefix-sets = [
        { prefix-set-name = "uplink-ipv4";
          prefix-list = lib.lists.map
            (p: { ip-prefix = p; })
            fabric.uplinks.${hostName}.allowed-prefixes4;
        }
        { prefix-set-name = "uplink-ipv6";
          prefix-list = lib.lists.map
            (p: { ip-prefix = p; })
            fabric.uplinks.${hostName}.allowed-prefixes6;
        }
        { prefix-set-name = "default-ipv6";
          prefix-list = [ { ip-prefix = "::/0"; } ];
        }
        { prefix-set-name = "freerange-endpoint";
          prefix-list = [ { ip-prefix = "206.83.40.91/32"; } ];
        }
      ];
      defined-sets.neighbor-sets = [
        { neighbor-set-name = "uplink";
          neighbor-info-list = [ fabric.uplinks.${hostName}.peer4 fabric.uplinks.${hostName}.peer6 ];
        }
      ];
      policy-definitions = [
        { name = "uplink-routes";
          statements = [
            { conditions.match-prefix-set = {
                prefix-set = "uplink-ipv4";
                match-set-options = "any";
              };
              actions.route-disposition = "accept-route";
            }
            { conditions.match-prefix-set = {
                prefix-set = "uplink-ipv6";
                match-set-options = "any";
              };
              actions.route-disposition = "accept-route";
            }
          ];
        }
        { name = "routes-import";
          statements = [
            { conditions.match-prefix-set = {
                prefix-set = "freerange-endpoint";
                match-set-options = "any";
              };
              conditions.bgp-conditions.route-type = "local";
              actions.route-disposition = "accept-route";
            }
            { conditions.match-prefix-set = {
                prefix-set = "default-ipv6";
                match-set-options = "any";
              };
              conditions.bgp-conditions.route-type = "local";
              actions.route-disposition = "accept-route";
            }
          ];
        }
        { name = "routes-export";
          statements = [
            { conditions.match-neighbor-set = {
                neighbor-set = "uplink";
                match-set-options = "invert";
              };
              conditions.match-prefix-set = {
                prefix-set = "freerange-endpoint";
                match-set-options = "any";
              };
              actions.route-disposition = "accept-route";
            }
            { conditions.match-neighbor-set = {
                neighbor-set = "uplink";
                match-set-options = "invert";
              };
              conditions.match-prefix-set = {
                prefix-set = "default-ipv6";
                match-set-options = "any";
              };
              actions.route-disposition = "accept-route";
            }
          ];
        }
        { name = "export-next-hop";
          statements = [
            { conditions.match-neighbor-set = {
                neighbor-set = "uplink";
                match-set-options = "invert";
              };
              conditions.match-prefix-set = {
                prefix-set = "default-ipv6";
                match-set-options = "any";
              };
              actions.bgp-actions.set-next-hop = "self";
            }
          ] ++ (lib.lists.map
            (l: {
              conditions.match-neighbor-set = {
                neighbor-set = name l;
                match-set-options = "any";
              };
              conditions.match-prefix-set = {
                prefix-set = "freerange-endpoint";
                match-set-options = "any";
              };
              actions.bgp-actions.set-next-hop = linkLocal_address
                (ip4Namespace fabric normalizedLinks l.linkId)
                hostName;
            })
            (linksInvolving hostName normalizedLinks));
        }
      ];
    };
  };
}
