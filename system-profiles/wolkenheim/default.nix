{ flake, config, hostName, lib, pkgs, ... }:
with (import ./utils.nix { inherit lib flake; });
let
  wolkenheimFabric = config.networking.wolkenheim.fabric;

  boronGobgpConfig = {
    global = {
      config = {
        as = hostASN wolkenheimFabric "boron";
        router-id = private_address
          wolkenheimFabric.ip4NamespaceAllocation.reserved_router_id
          hostIds.boron;
        port = -1;
      };
      apply-policy.config = {
        import-policy-list = [
          "vultr-prefixes"
          "default-route"
        ];
        default-import-policy = "reject-route";
        export-policy-list = [
          "replace-next-hop-dsl"
          "replace-next-hop-lte"
          "demote-lte"

          "vultr-prefixes"
        ];
        default-export-policy = "reject-route";
      };
    };
    zebra.config = {
      enabled = true;
      url = "unix:///run/frr/zserv.api";
      redistribute-route-type-list = [ "static" "directly-connected" ];
      version = 6;
    };
    peer-groups = [
      { config = {
          peer-group-name = "wolkenheim";
        };
        timers.config = {
          hold-time = 9;
          keepalive-interval = 3;
        };
        afi-safis = [
          { config.afi-safi-name = "ipv4-unicast"; }
          { config.afi-safi-name = "ipv6-unicast"; }
        ];
      }
    ];
    neighbors = [
      { config = {
          neighbor-interface = "lanthanum-dsl";
          peer-group = "wolkenheim";
        };
      }
      { config = {
          neighbor-interface = "lanthanum-lte";
          peer-group = "wolkenheim";
        };
      }
    ];
    defined-sets.prefix-sets = [
      { prefix-set-name = "vultr-ipv6";
        prefix-list = [
          { ip-prefix = "2001:19f0:6c01:2bc5::/64"; }
        ];
      }
      { prefix-set-name = "vultr-ipv4";
        prefix-list = [
          { ip-prefix = "45.77.54.162/32"; }
        ];
      }
      { prefix-set-name = "default-ipv4";
        prefix-list = [ { ip-prefix = "0.0.0.0/0"; } ];
      }
      { prefix-set-name = "default-ipv6";
        prefix-list = [ { ip-prefix = "::/0"; } ];
      }
    ];
    defined-sets.neighbor-sets = [
      { neighbor-set-name = "lanthanum-dsl";
        neighbor-info-list = [
          "fe80:3e0e:b7ec:a2f6:16a3:5034:d409:3b73"
        ];
      }
      { neighbor-set-name = "lanthanum-lte";
        neighbor-info-list = [
          "fe80:3e0e:b7ec:2cf1:bb2b:4a18:d409:3b73"
        ];
      }
    ];
    policy-definitions = [
      { name = "vultr-prefixes";
        statements = [
          {
            conditions.match-prefix-set = {
              prefix-set = "vultr-ipv4";
              match-set-options = "any";
            };
            actions.route-disposition = "accept-route";
          }
          {
            conditions.match-prefix-set = {
              prefix-set = "vultr-ipv6";
              match-set-options = "any";
            };
            actions.route-disposition = "accept-route";
          }
        ];
      }
      { name = "replace-next-hop-dsl";
        statements = [
          { conditions.match-prefix-set = {
              prefix-set = "vultr-ipv4";
              match-set-options = "any";
            };
            conditions.match-neighbor-set = {
              neighbor-set = "lanthanum-dsl";
              match-set-options = "any";
            };
            actions.bgp-actions = {
              set-next-hop = "169.254.52.5";
            };
          }
        ];
      }
      { name = "replace-next-hop-lte";
        statements = [
          { conditions.match-prefix-set = {
              prefix-set = "vultr-ipv4";
              match-set-options = "any";
            };
            conditions.match-neighbor-set = {
              neighbor-set = "lanthanum-lte";
              match-set-options = "any";
            };
            actions.bgp-actions = {
              set-next-hop = "169.254.24.5";
            };
          }
        ];
      }
      { name = "demote-lte";
        statements = [
          { conditions.match-neighbor-set = {
              neighbor-set = "lanthanum-lte";
              match-set-options = "any";
            };
            actions.bgp-actions = {
              set-as-path-prepend = {
                as = "last-as";
                repeat-n = 1;
              };
            };
          }
        ];
      }
      { name = "default-route";
        statements = [
          { conditions.match-neighbor-set = {
              neighbor-set = "lanthanum-dsl";
              match-set-options = "any";
            };
            conditions.match-prefix-set = {
              prefix-set = "default-ipv4";
              match-set-options = "any";
            };
            actions.route-disposition = "accept-route";
          }
          { conditions.match-neighbor-set = {
              neighbor-set = "lanthanum-dsl";
              match-set-options = "any";
            };
            conditions.match-prefix-set = {
              prefix-set = "default-ipv6";
              match-set-options = "any";
            };
            actions.route-disposition = "accept-route";
          }
          { conditions.match-neighbor-set = {
              neighbor-set = "lanthanum-lte";
              match-set-options = "any";
            };
            conditions.match-prefix-set = {
              prefix-set = "default-ipv4";
              match-set-options = "any";
            };
            actions.bgp-actions.set-as-path-prepend = {
              as = "last-as";
              repeat-n = 1;
            };
            actions.route-disposition = "accept-route";
          }
          { conditions.match-neighbor-set = {
              neighbor-set = "lanthanum-lte";
              match-set-options = "any";
            };
            conditions.match-prefix-set = {
              prefix-set = "default-ipv6";
              match-set-options = "any";
            };
            actions.bgp-actions.set-as-path-prepend = {
              as = "last-as";
              repeat-n = 1;
            };
            actions.route-disposition = "accept-route";
          }
        ];
      }
    ];
  };
in {
  options = {
    networking.wolkenheim = {
      fabric = lib.mkOption {
        description = "Wolkenheim fabric description";
        default = import ./fabric.nix;
        type = lib.types.attrs;
      };
    };
  };
  imports = [ ./wireguard-links.nix ./bgp.nix ./bfd.nix ];
  config = lib.mkMerge [{
    system.build.uncheckedIp4NamespaceMap = uncheckedIp4NamespaceMap wolkenheimFabric (normalize wolkenheimFabric.links);
  }
  (lib.mkIf (hostName == "boron") {
    networking.gobgpd.config = lib.mkForce boronGobgpConfig;
  }) ];
}
