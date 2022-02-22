{ flake, config, hostName, lib, pkgs, ... }:
with (import ./utils.nix { inherit lib flake; });
let
  wolkenheimFabric = import ./fabric.nix;

  wgNetworkd = host: fabric: let
    normalizedLinks = normalize fabric.links;

    name = l: intfName (remote l).host l.from.intf;

    remote = l: if linkIsFrom host l
                  then l.to
                  else l.from;

    netdevs = lib.attrsets.listToAttrs (lib.lists.map
      (l: let
        ip6Ns = l.linkId;
        ip4Ns = ip4Namespace fabric normalizedLinks ip6Ns;
      in lib.attrsets.nameValuePair "40-${name l}" {
        netdevConfig = {
          Name = name l;
          Kind = "wireguard";
          MTUBytes = "1412";
        };
        wireguardConfig = {
          PrivateKeyFile = "/run/agenix/${host}";
        } // lib.attrsets.optionalAttrs (linkIsTo host l) {
          ListenPort = linkListenPort ip4Ns;
        };
        wireguardPeers = [
          { wireguardPeerConfig = {
            PublicKey = lib.strings.removeSuffix "\n" (builtins.readFile (
              ../../wireguard + "/${(remote l).host}.pub"));
            AllowedIPs = [ "0.0.0.0/0" "::/0" ];
          } // lib.attrsets.optionalAttrs (linkIsFrom host l) {
            Endpoint = "${(remote l).host}.kleen.org:${builtins.toString (linkListenPort ip4Ns)}";
          }; }
        ];
        extraConfig = ''
          [Match]
        '';
      })
      (linksInvolving host normalizedLinks));

    networks = lib.attrsets.listToAttrs (lib.lists.map
      (l: let
        ip6Ns = l.linkId;
        ip4Ns = ip4Namespace fabric normalizedLinks ip6Ns;
        localAS = fabric.AS.${fabric.hosts.${host}.AS};
      in lib.attrsets.nameValuePair "40-${name l}" ({
        name = name l;
        address = [
          "${private_address ip4Ns hostIds.${host}}/16"
          "${private_address6 ip6Ns hostIds.${host}}/96" 
        ];
        extraConfig = ''
          [Neighbor]
          Address=${private_address6 ip6Ns hostIds.${(remote l).host}}
          LinkLayerAddress=${private_address6 ip6Ns hostIds.${(remote l).host}}
        '';
      } // lib.attrsets.optionalAttrs (linkIsFrom host l && localAS.announcePublic) { # HACK: change me to zebra
        routingPolicyRules = [
          { routingPolicyRuleConfig = { Table = ip4Ns; From = localAS.public; Priority = ip4Ns; }; }
          { routingPolicyRuleConfig = { Table = ip4Ns; From = localAS.public6; Priority = ip4Ns; }; }
        ];
        routes = [
          { routeConfig = { Gateway = "${private_address ip4Ns hostIds.${(remote l).host}}"; Table = ip4Ns; }; }
          { routeConfig = { Gateway = "${private_address6 ip6Ns hostIds.${(remote l).host}}"; Table = ip4Ns; }; }
        ];
      }))
      (linksInvolving host normalizedLinks));
  in {
    inherit netdevs networks;
  };

  zebraConfig = pkgs.writeText "zebra.conf" ''
    hostname ${hostName}
    log syslog
    service password-encryption
    ip nht resolve-via-default
  '';

  gobgpConfig = {
    global = {
      config = {
        as = hostAS wolkenheimFabric hostName;
        router-id = "45.32.153.151";
        port = 179;
      };
      apply-policy.config = {
        import-policy-list = [ "allow-vultr-allowed-adv" ];
        default-import-policy = "reject-route";
        export-policy-list = [ "allow-vultr-allowed-adv" ];
        default-export-policy = "reject-route";
      };
    };
    zebra.config = {
      enabled = true;
      url = "unix:///run/frr/zserv.api";
      redistribute-route-type-list = [];
      version = 6;
    };
    peer-groups = [
      { config = {
          peer-group-name = "auenheim";
          peer-as = ASN "auenheim";
        };
        timers.config = {
          hold-time = 3;
          keepalive-interval = 1;
        };
        afi-safis = [
          { config.afi-safi-name = "ipv4-unicast"; }
          { config.afi-safi-name = "ipv6-unicast"; }
        ];
        apply-policy.config = {
          import-policy-list = [ "allow-vultr-allowed-adv" ];
          default-import-policy = "reject-route";
          export-policy-list = [ ];
          default-export-policy = "reject-route";
        };
      }
      { config = {
          peer-group-name = "vultr";
          peer-as = 64515;
          local-as = 4288000175;
          auth-password = "$VULTR_BGP_PASSWORD";
        };
        timers.config = {
          hold-time = 3;
          keepalive-interval = 1;
        };
        ebgp-multihop.config = {
          enabled = true;
          multihop-ttl = 2;
        };
        apply-policy.config = {
          import-policy-list = [ ];
          default-import-policy = "reject-route";
          export-policy-list = [ "allow-vultr-allowed-adv" ];
          default-export-policy = "reject-route";
        };
      }
    ];
    neighbors = [
      { config = {
          neighbor-interface = "boron-dsl";
          peer-group = "auenheim";
        };
        transport.config = {
          passive-mode = true;
        };
      }
      { config = {
          neighbor-interface = "boron-lte";
          peer-group = "auenheim";
        };
        transport.config = {
          passive-mode = true;
        };
      }
      { config = {
          neighbor-address = "169.254.169.254";
          peer-group = "vultr";
          remove-private-as = "all";
        };
        afi-safis = [
          { config.afi-safi-name = "ipv4-unicast"; }
        ];
      }
      { config = {
          neighbor-address = "2001:19f0:ffff::1";
          peer-group = "vultr";
          remove-private-as = "all";
        };
        afi-safis = [
          { config.afi-safi-name = "ipv6-unicast"; }
        ];
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
    ];
    policy-definitions = [
      { name = "allow-vultr-allowed-adv";
        statements = [
          { conditions.match-prefix-set = {
              prefix-set = "vultr-ipv4";
              match-set-options = "any";
            };
            actions.route-disposition = "accept-route";
          }
          { conditions.match-prefix-set = {
              prefix-set = "vultr-ipv6";
              match-set-options = "any";
            };
            actions.route-disposition = "accept-route";
          }
        ];
      }
    ];
  };

  boronGobgpConfig = {
    global = {
      config = {
        as = hostAS wolkenheimFabric "boron";
        router-id = private_address
          wolkenheimFabric.ip4NamespaceAllocation.reserved_router_id
          hostIds.boron;
        port = -1;
      };
      apply-policy.config = {
        import-policy-list = [ "allow-vultr-allowed-adv" ];
        default-import-policy = "reject-route";
        export-policy-list = [
          "replace-next-hop-dsl"
          "replace-next-hop-lte"
          "demote-lte"
          "allow-vultr-allowed-adv"
        ];
        default-export-policy = "reject-route";
      };
    };
    peer-groups = [
      { config = {
          peer-group-name = "wolkenheim";
        };
        timers.config = {
          hold-time = 3;
          keepalive-interval = 1;
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
      { name = "allow-vultr-allowed-adv";
        statements = [
          { conditions.match-prefix-set = {
              prefix-set = "vultr-ipv4";
              match-set-options = "any";
            };
            actions.route-disposition = "accept-route";
          }
          { conditions.match-prefix-set = {
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
              set-next-hop = "10.52.114.197";
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
              set-next-hop = "10.24.114.197";
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
    ];
  };
in {
  config = lib.mkMerge [{
    system.build.uncheckedIp4NamespaceMap = uncheckedIp4NamespaceMap wolkenheimFabric (normalize wolkenheimFabric.links);
    system.build.wgNetworkd = wgNetworkd hostName wolkenheimFabric;
    networking.firewall.checkReversePath = "loose";
    systemd.network = wgNetworkd hostName wolkenheimFabric;
    environment.systemPackages = [ pkgs.wireguard-tools ];
  }
  (lib.mkIf (hostName == "boron") {
    systemd.network = {
      netdevs."40-vultr" = {
        netdevConfig = {
          Name = "vultr";
          Kind = "dummy";
        };
        extraConfig = ''
          [Match]
        '';
      };
      networks."40-vultr" = {
        name = "vultr";
        address = [
          "45.77.54.162/32"
          "2001:19f0:6c01:2bc5::1/64"
        ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };
    };

    environment.systemPackages = [
      pkgs.gobgp
    ];
    systemd.services.gobgpd = let
      configFile = (pkgs.formats.toml {}).generate "gobgpd.conf" boronGobgpConfig;
      finalConfigFile = "$RUNTIME_DIRECTORY/gobgpd.conf";
    in {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "systemd-sysctl.service" ];
      description = "GoBGP Routing Daemon";
      script = ''
        umask 077
        ${pkgs.envsubst}/bin/envsubst -i "${configFile}" > ${finalConfigFile}
        exec ${pkgs.gobgpd}/bin/gobgpd -f "${finalConfigFile}" --sdnotify --pprof-disable --api-hosts=unix://"$RUNTIME_DIRECTORY/gobgpd.sock"
      '';
      postStart = ''
        ${pkgs.gobgp}/bin/gobgp --target unix://"$RUNTIME_DIRECTORY/gobgpd.sock" global rib add 45.77.54.162/32 origin igp -a ipv4
        ${pkgs.gobgp}/bin/gobgp --target unix://"$RUNTIME_DIRECTORY/gobgpd.sock" global rib add 2001:19f0:6c01:2bc5::/64 origin igp -a ipv6
      '';
      serviceConfig = {
        Type = "notify";
        ExecReload = "${pkgs.gobgpd}/bin/gobgpd -r";
        DynamicUser = true;
        RuntimeDirectoryMode = "0700";
        RuntimeDirectory = "gobgpd";
        CapabilityBoundingSet = "";
      };
    };
  })
  (lib.mkIf (hostName == "lanthanum") {
    networking.firewall.allowedUDPPorts = lib.lists.concatMap
      (l: if l.listenPort != null then [ l.listenPort ] else [])
      (lib.attrsets.attrValues config.networking.wireguard.interfaces);

    environment.etc = {
      "frr/zebra.conf".source = zebraConfig;
      "frr/vtysh.conf".text = "";
    };
    environment.systemPackages = [
      pkgs.frr pkgs.gobgp pkgs.gobgpd
    ];
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
        ExecStart = "${pkgs.frr}/libexec/frr/zebra -f /etc/frr/zebra.conf --vty_addr localhost";
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

    systemd.services.gobgpd = let
      configFile = (pkgs.formats.toml {}).generate "gobgpd.conf" gobgpConfig;
      finalConfigFile = "$RUNTIME_DIRECTORY/gobgpd.conf";
    in {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "systemd-sysctl.service" "zebra.service" ];
      bindsTo = [ "zebra.service" ];
      description = "GoBGP Routing Daemon";
      script = ''
        umask 077
        export $(xargs < "''${CREDENTIALS_DIRECTORY}"/vultr-bgp-password)
        ${pkgs.envsubst}/bin/envsubst -i "${configFile}" > ${finalConfigFile}
        exec ${pkgs.gobgpd}/bin/gobgpd -f "${finalConfigFile}" --sdnotify --pprof-disable --api-hosts=unix://"$RUNTIME_DIRECTORY/gobgpd.sock"
      '';
      serviceConfig = {
        Type = "notify";
        ExecReload = "${pkgs.gobgpd}/bin/gobgpd -r";
        User = "frr";
        Group = "frr";
        RuntimeDirectoryMode = "0700";
        RuntimeDirectory = "gobgpd";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        LoadCredential = [
          "vultr-bgp-password:/run/agenix/vultr-bgp-password"
        ];
      };
    };
    age.secrets."vultr-bgp-password" = {
      file = ../../secrets/wolkenheim/vultr-bgp-password + "-${config.networking.hostName}.age";
    };
  })];
}
