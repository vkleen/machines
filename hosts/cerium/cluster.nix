{ lib, pkgs, flake, config, ...}:
let
  inherit (builtins) substring;
  inherit (import ../../utils/ints.nix { inherit lib; }) hexToInt;

  private_address = host: let
    machine_id = flake.nixosConfigurations.${host}.config.environment.etc."machine-id".text;
    chars12 = substring 0 2 machine_id;
    chars34 = substring 2 2 machine_id;

    octet1 = hexToInt chars12;
    octet2 = hexToInt chars34;
  in "10.32.${builtins.toString octet1}.${builtins.toString octet2}";

  mkId = host: let
    machine_id = flake.nixosConfigurations.${host}.config.environment.etc."machine-id".text;
    first_halfword = substring 0 4 machine_id;
    idInt = hexToInt first_halfword;
  in builtins.toString idInt;

  node = host: ''
    node {
      name: ${host}
      nodeid: ${mkId host}
      ring0_addr: ${private_address host}
    }
  '';

  corosyncConf = pkgs.writeText "corosync.conf" ''
    totem {
      version: 2
      netmtu: 1450
      cluster_name: wolkenheim

      ip_version: ipv4

      crypto_cipher: none
      crypto_hash: none
    }
    logging {
      fileline: off
      to_stderr: no
      to_logfile: no
      to_syslog: yes
      debug: off
      logger_subsys {
        subsys: QUORUM
        debug: off
      }
    }
    quorum {
      provider: corosync_votequorum
      last_man_standing: 1
    }
    nodelist {
      ${node "lanthanum"}
      ${node "cerium"}
    }
  '';
in {
  config = {
    environment.systemPackages = [
      pkgs.pacemaker
      pkgs.corosync
      pkgs.pcs
      pkgs.gobgpd
      pkgs.gobgp
    ];
    environment.etc."corosync/corosync.conf".source = corosyncConf;
    systemd = {
      packages = [ pkgs.corosync pkgs.pacemaker ];
      services.corosync = {
        preStart = ''
          mkdir -p /var/lib/corosync
        '';
        restartTriggers = [ corosyncConf ];
      };
      services.pacemaker.wantedBy = [ "multi-user.target" ];
    };

    users = {
      users.hacluster = {
        group = "haclient";
        isSystemUser = true;
        uid = 189;
      };

      groups.haclient = {
        gid = 189;
      };
    };

    services.gobgpd = {
      settings = {
        global = {
          config = {
            as = 4288000175;
            router-id = "45.32.154.225";
            port = -1;
          };
        };
        neighbors = [
          { config = {
              neighbor-address = "169.254.169.254";
              peer-as = 64515;
              auth-password = "$BGP_AUTH_PASSWORD";
            };
            ebgp-multihop = {
              config = {
                enabled = true;
                multihop-ttl = 2;
              };
            };
          }
          { config = {
              neighbor-address = "2001:19f0:ffff::1";
              peer-as = 64515;
              auth-password = "$BGP_AUTH_PASSWORD";
            };
            ebgp-multihop = {
              config = {
                enabled = true;
                multihop-ttl = 2;
              };
            };
            transport = {
              config = {
                local-address = "2001:19f0:6c01:284a:5400:03ff:fec6:c9b0";
              };
            };
            afi-safis = [
              { config = {
                afi-safi-name = "ipv6-unicast";
              }; }
            ];
          }
        ];
        policy-definitions = [
          { name = "prepend-as";
            statements = [
              { actions = {
                  bgp-actions = {
                    set-as-path-prepend = {
                      as = 4288000175;
                      repeat-n = 1;
                    };
                  };
                };
              }
            ];
          }
        ];
      };
    };

    systemd.services.gobgpd = let
      configFile = (pkgs.formats.toml {}).generate "gobgpd.conf" config.services.gobgpd.settings;
      finalConfigFile = "$RUNTIME_DIRECTORY/gobgpd.conf";
    in {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "GoBGP Routing Daemon";
      script = ''
        umask 077
        export $(xargs < "''${CREDENTIALS_DIRECTORY}"/auth-password)
        ${pkgs.envsubst}/bin/envsubst -i "${configFile}" > ${finalConfigFile}
        exec ${pkgs.gobgpd}/bin/gobgpd -f "${finalConfigFile}" --sdnotify --pprof-disable --api-hosts=unix://"$RUNTIME_DIRECTORY/gobgpd.sock"
      '';
      postStart = ''
        ${pkgs.gobgp}/bin/gobgp --target unix://"$RUNTIME_DIRECTORY/gobgpd.sock" global rib add 45.77.54.162/32 -a ipv4
        ${pkgs.gobgp}/bin/gobgp --target unix://"$RUNTIME_DIRECTORY/gobgpd.sock" global rib add 2001:19f0:6c01:2bc5::1/64 -a ipv6
      '';
      serviceConfig = {
        Type = "notify";
        ExecReload = "${pkgs.gobgpd}/bin/gobgpd -r";
        DynamicUser = true;
        AmbientCapabilities = "cap_net_bind_service";
        RuntimeDirectoryMode = "0700";
        RuntimeDirectory = "gobgpd";
        LoadCredential = [
          "auth-password:/run/agenix/gobgp-auth-password"
        ];
      };
    };

    age.secrets."gobgp-auth-password" = {
      file = ../../secrets/wolkenheim/gobgp-auth-password + "-${config.networking.hostName}.age";
    };
  };
}
