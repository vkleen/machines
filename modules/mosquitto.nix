{config, lib, pkgs, ...}:
with lib;
let
  cfg = config.services.mosquitto;

  listenerConf = l: ''
    listener ${toString l.port} ${l.host}
  '' + optionalString l.ssl.enable ''
    cafile ${l.ssl.cafile}
    certfile ${l.ssl.certfile}
    keyfile ${l.ssl.keyfile}
  '' + ''
    ${l.extraConf}
  '';

  listenersConf = concatStringsSep "\n\n" (map listenerConf cfg.listeners);

  passwordConf = optionalString cfg.checkPasswords ''
    password_file ${cfg.dataDir}/passwd
  '';

  mosquittoConf = pkgs.writeText "mosquitto.conf" ''
    acl_file ${aclFile}
    allow_anonymous ${boolToString cfg.allowAnonymous}
    ${passwordConf}
    ${listenersConf}
    ${cfg.extraConf}
  '';

  userAcl = (concatStringsSep "\n\n" (mapAttrsToList (n: c:
    "user ${n}\n" + (concatStringsSep "\n" c.acl)) cfg.users
  ));

  aclFile = pkgs.writeText "mosquitto.acl" ''
    ${cfg.aclExtraConf}
    ${userAcl}
  '';

  listenerModule = types.submodule {
    options = {
      ssl = {
        enable = mkEnableOption "SSL listener";

        cafile = mkOption {
          type = types.path;
          description = "Path to PEM encoded CA certificates.";
        };

        certfile = mkOption {
          type = types.path;
          description = "Path to PEM encoded server certificate.";
        };

        keyfile = mkOption {
          type = types.path;
          description = "Path to PEM encoded server key.";
        };
      };
      host = mkOption {
        default = "0.0.0.0";
        example = "localhost";
        type = types.str;
        description = ''
          Host to listen on.
        '';
      };

      port = mkOption {
        default = 1883;
        example = 1883;
        type = types.int;
        description = ''
          Port on which to listen.
        '';
      };

      extraConf = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra config to append to this listener.
        '';
      };
    };
  };
in {
  disabledModules = [ "services/networking/mosquitto.nix" ];
  options = {
    services.mosquitto = {
      enable = mkEnableOption "the MQTT Mosquitto broker";
      dataDir = mkOption {
        default = "/var/lib/mosquitto";
        type = types.path;
        description = ''
          The data directory.
        '';
      };
      listeners = mkOption {
        description = ''
          Configured listeners
        '';
        type = types.listOf listenerModule;
      };
      users = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            password = mkOption {
              type = with types; uniq (nullOr str);
              default = null;
              description = ''
                Specifies the (clear text) password for the MQTT User.
              '';
            };

            passwordFile = mkOption {
              type = with types; uniq (nullOr str);
              example = "/path/to/file";
              default = null;
              description = ''
                Specifies the path to a file containing the
                clear text password for the MQTT user.
              '';
            };

            hashedPassword = mkOption {
              type = with types; uniq (nullOr str);
              default = null;
              description = ''
                Specifies the hashed password for the MQTT User.
                To generate hashed password install <literal>mosquitto</literal>
                package and use <literal>mosquitto_passwd</literal>.
              '';
            };

            hashedPasswordFile = mkOption {
              type = with types; uniq (nullOr str);
              example = "/path/to/file";
              default = null;
              description = ''
                Specifies the path to a file containing the
                hashed password for the MQTT user.
                To generate hashed password install <literal>mosquitto</literal>
                package and use <literal>mosquitto_passwd</literal>.
              '';
            };

            acl = mkOption {
              type = types.listOf types.str;
              example = [ "topic read A/B" "topic A/#" ];
              description = ''
                Control client access to topics on the broker.
              '';
            };
          };
        });
        example = { john = { password = "123456"; acl = [ "topic readwrite john/#" ]; }; };
        description = ''
          A set of users and their passwords and ACLs.
        '';
      };

      allowAnonymous = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Allow clients to connect without authentication.
        '';
      };

      checkPasswords = mkOption {
        default = false;
        example = true;
        type = types.bool;
        description = ''
          Refuse connection when clients provide incorrect passwords.
        '';
      };

      extraConf = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra config to append to `mosquitto.conf` file.
        '';
      };

      aclExtraConf = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra config to prepend to the ACL file.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    assertions = mapAttrsToList (name: cfg: {
      assertion = length (filter (s: s != null) (with cfg; [
        password passwordFile hashedPassword hashedPasswordFile
      ])) <= 1;
      message = "Cannot set more than one password option";
    }) cfg.users;

    systemd.services.mosquitto = {
      description = "Mosquitto MQTT Broker Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "notify";
        NotifyAccess = "main";
        User = "mosquitto";
        Group = "mosquitto";
        RuntimeDirectory = "mosquitto";
        WorkingDirectory = cfg.dataDir;
        Restart = "on-failure";
        ExecStart = "${pkgs.mosquitto}/bin/mosquitto -c ${mosquittoConf}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      };
      preStart = ''
        rm -f ${cfg.dataDir}/passwd
        touch ${cfg.dataDir}/passwd
      '' + concatStringsSep "\n" (
        mapAttrsToList (n: c:
          if c.hashedPasswordFile != null then
            "echo '${n}:'$(cat '${c.hashedPasswordFile}') >> ${cfg.dataDir}/passwd"
          else if c.passwordFile != null then
            "${pkgs.mosquitto}/bin/mosquitto_passwd -b ${cfg.dataDir}/passwd ${n} $(cat '${c.passwordFile}')"
          else if c.hashedPassword != null then
            "echo '${n}:${c.hashedPassword}' >> ${cfg.dataDir}/passwd"
          else optionalString (c.password != null)
            "${pkgs.mosquitto}/bin/mosquitto_passwd -b ${cfg.dataDir}/passwd ${n} '${c.password}'"
        ) cfg.users);
    };

    users.users.mosquitto = {
      description = "Mosquitto MQTT Broker Daemon owner";
      group = "mosquitto";
      uid = config.ids.uids.mosquitto;
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.mosquitto.gid = config.ids.gids.mosquitto;  };
}
