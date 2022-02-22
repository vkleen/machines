{ lib, pkgs, flake, config, ...}:
let
  inherit (builtins) substring;
  inherit (import ../../utils/ints.nix { inherit lib; }) hexToInt;
  inherit (import ../../utils { inherit lib; }) private_address;
  private_address' = host: private_address 32 flake.nixosConfigurations.${host}.config.environment.etc."machine-id".text;

  mkId = host: let
    machine_id = flake.nixosConfigurations.${host}.config.environment.etc."machine-id".text;
    first_halfword = substring 0 4 machine_id;
    idInt = hexToInt first_halfword;
  in builtins.toString idInt;

  node = host: ''
    node {
      name: ${host}
      nodeid: ${mkId host}
      ring0_addr: ${private_address' host}
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
    system {
      state_dir: $RUNTIME_DIRECTORY
      move_to_root_cgroup: no
    }
    logging {
      fileline: off
      to_stderr: no
      to_logfile: no
      to_syslog: yes
      debug: off
      blackbox: off
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

  pacemaker = pkgs.pacemaker;

  bfdConfig = (pkgs.formats.yaml {}).generate "bfdd.yaml" {
    listen = [ "${private_address 64 config.environment.etc."machine-id".text}" ];
    peers = {
      "${private_address 64 flake.nixosConfigurations.boron.config.environment.etc."machine-id".text}" = {
        name = "boron";
        port = 3784;
        interval = 250;
        detectionMultiplier = 2;
      };
    };
  };
in {
  config = {
#    boot.kernel.sysctl = {
#      "net.core.wmem_max" = 8388608;
#      "net.core.rmem_max" = 8388608;
#    };

    environment.systemPackages = [
#      pacemaker
#      pkgs.corosync
#      pkgs.pcs
      pkgs.gobgpd
      pkgs.gobgp
      pkgs.bfd
    ];
#    systemd.services = {
#      corosync = {
#        description = "Corosync Cluster Engine";
#        documentation = [ "man:corosync" "man:corosync.conf" "man:corosync_overview" ];
#        requires = [ "network-online.target" ];
#        after = [ "network-online.target" ];
#        script = ''
#          ${pkgs.envsubst}/bin/envsubst -i "${corosyncConf}" > "$RUNTIME_DIRECTORY/corosync.conf"
#          cat "$RUNTIME_DIRECTORY/corosync.conf"
#          exec ${pkgs.corosync}/sbin/corosync -f -c "$RUNTIME_DIRECTORY/corosync.conf"
#        '';
#        serviceConfig = {
#          Type = "notify";
#          StandardError = "null";
#          ExecStop = "${pkgs.corosync}/sbin/corosync-cfgtool -H --force";
#          RuntimeDirectory = "corosync";
#          RestrictRealtime = "no";
#          LimitMEMLOCK="infinity";
#        };
#      };
#
#      pacemaker = {
#        description = "Pacemaker High Availability CLuster Manager";
#        documentation = [ "man:pacemakerd" "https://clusterlabs.org/pacemaker/doc" ];
#        after = [
#          "network.target"
#          "time-sync.target"
#          "dbus.service"
#          "resource-agent-deps.target"
#          "syslog.service"
#          "rsyslog.service"
#          "corosync.service"
#        ];
#        wants = [
#          "dbus.service"
#          "resource-agent-deps.service"
#        ];
#        wantedBy = [ "multi-user.target" ];
#        requires = [ "corosync.service" ];
#        startLimitBurst = 5;
#        startLimitIntervalSec = 25;
#
#        serviceConfig = {
#          ExecStart = "${pacemaker}/sbin/pacemakerd";
#          KillMode = "process";
#          NotifyAccess = "main";
#          Restart = "on-failure";
#          RestartSec = "1s";
#          SendSIGKILL = "no";
#          StandardError = "null";
#          SuccessExitStatus = "100";
#          TimeoutStartSec = "60s";
#          TimeoutStopSec = "30min";
#        };
#      };
#    };

#    users = {
#      users.hacluster = {
#        group = "haclient";
#        isSystemUser = true;
#        uid = 189;
#      };
#
#      groups.haclient = {
#        gid = 189;
#      };
#    };

    services.gobgpd = {
      settings = {
        global = {
          config = {
            as = 4288000175;
            router-id = "45.32.153.151";
            port = -1;
          };
          apply-policy = {
            config = {
              import-policy-list = [];
              default-import-policy = "accept-route";
              export-policy-list = [ "prepend-as" ];
              default-export-policy = "accept-route";
            };
          };
        };
        neighbors = [
          { config = {
              neighbor-address = "169.254.169.254";
              peer-as = 64515;
              auth-password = "$BGP_AUTH_PASSWORD";
            };
            timers = {
              config = {
                hold-time = 3;
                keepalive-interval = 1;
              };
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
            timers = {
              config = {
                hold-time = 3;
                keepalive-interval = 1;
              };
            };
            ebgp-multihop = {
              config = {
                enabled = true;
                multihop-ttl = 2;
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

#    systemd.services.gobgpd = let
#      configFile = (pkgs.formats.toml {}).generate "gobgpd.conf" config.services.gobgpd.settings;
#      finalConfigFile = "$RUNTIME_DIRECTORY/gobgpd.conf";
#    in {
#      #wantedBy = [ "multi-user.target" ];
#      after = [ "network.target" ];
#      description = "GoBGP Routing Daemon";
#      script = ''
#        umask 077
#        export $(xargs < "''${CREDENTIALS_DIRECTORY}"/auth-password)
#        ${pkgs.envsubst}/bin/envsubst -i "${configFile}" > ${finalConfigFile}
#        exec ${pkgs.gobgpd}/bin/gobgpd -f "${finalConfigFile}" --sdnotify --pprof-disable --api-hosts=unix://"$RUNTIME_DIRECTORY/gobgpd.sock"
#      '';
#      postStart = ''
#        ${pkgs.gobgp}/bin/gobgp --target unix://"$RUNTIME_DIRECTORY/gobgpd.sock" global rib add 45.77.54.162/32 -a ipv4
#        ${pkgs.gobgp}/bin/gobgp --target unix://"$RUNTIME_DIRECTORY/gobgpd.sock" global rib add 2001:19f0:6c01:2bc5::/64 -a ipv6
#      '';
#      serviceConfig = {
#        Type = "notify";
#        ExecReload = "${pkgs.gobgpd}/bin/gobgpd -r";
#        DynamicUser = true;
#        RuntimeDirectoryMode = "0700";
#        RuntimeDirectory = "gobgpd";
#        LoadCredential = [
#          "auth-password:/run/agenix/gobgp-auth-password"
#        ];
#      };
#    };
#
#    age.secrets."gobgp-auth-password" = {
#      file = ../../secrets/wolkenheim/gobgp-auth-password + "-${config.networking.hostName}.age";
#    };

    systemd.services.bfdd = {
      #wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "wireguard-boron.service" ];
      requires = [ "wireguard-boron.service" ];
      script = ''
        exec ${pkgs.bfdd}/bin/bfdd -s "$RUNTIME_DIRECTORY/bfdd.sock" -c "${bfdConfig}"
      '';
      serviceConfig = {
        Type = "simple";
        RuntimeDirectoryMode = "0700";
        RuntimeDirectory = "bfdd";
        DynamicUser = true;
      };
    };
  };
}
