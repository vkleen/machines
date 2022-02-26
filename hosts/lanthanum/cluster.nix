{ lib, pkgs, flake, config, ...}:
let
  inherit (builtins) substring;
  inherit (flake.inputs.utils.lib.ints) hexToInt;
  inherit (flake.inputs.utils.lib) private_address;
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
