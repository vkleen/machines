{ config, lib, pkgs, ... }:

with lib;

let
  knownHostsFile = pkgs.writeText "known_hosts" cfg.sshHosts;
  sshConfigFile = pkgs.writeText "uucp_ssh_config" cfg.sshConfig;
  # Don't use quotes, uucp doesn't understand them
  portSpec = name: ''
    port ${name}
    type pipe
    protocol ${if builtins.hasAttr name cfg.protocols then cfg.protocols."${name}" else cfg.defaultProtocol}
    reliable true
    command ${pkgs.openssh}/bin/ssh -x -F ${sshConfigFile} -o UserKnownHostsFile=${knownHostsFile} -o HostKeyAlias=${name} -o batchmode=yes ${name}
  '';
  sysSpec = name: ''
    system ${name}
    time Any
    port ${name}
    chat ""
    protocol ${if builtins.hasAttr name cfg.protocols then cfg.protocols."${name}" else cfg.defaultProtocol}
    command-path ${concatStringsSep " " cfg.commandPath}
    commands ${concatStringsSep " " (if builtins.hasAttr name cfg.commands then cfg.commands."${name}" else cfg.defaultCommands)}
  '';

  cfg = config.services.uucp;
in {
  options = {
    services.uucp = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If enabled we set up an account accesible via uucp over ssh
        '';
      };

      nodeName = mkOption {
        type = types.str;
        default = "nixos";
        description = "uucp node name";
      };

      sshUser = mkOption {
        type = types.attrs;
        default = {};
        description = "Overrides for the local uucp linux-user";
      };

      sshConfig = mkOption {
        type = types.str;
        default = "";
        description = "~uucp/.ssh/config";
      };

      sshHosts = mkOption {
        type = types.lines;
        default = "";
        description = "known_hosts entries";
      };

      remoteNodes = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Ports to set up
          Names will probably need to be configured in sshConfig
        '';
      };

      commandPath = mkOption {
        type = types.listOf types.path;
        default = [ "${pkgs.rmail config.security.wrapperDir}/bin" ];
        description = ''
          Command search path for all systems
        '';
      };

      defaultCommands = mkOption {
        type = types.listOf types.str;
        default = ["rmail"];
        description = "Commands allowed for remotes without explicit override";
      };

      commands = mkOption {
        type = types.attrsOf (types.listOf types.str);
        default = {};
        description = "Override commands for specific remotes";
      };

      defaultProtocol = mkOption {
        type = types.str;
        default = "e";
        description = "UUCP protocol to use within ssh unless overriden";
      };

      protocols = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "UUCP protocols to use for specific remotes";
      };

      spoolDir = mkOption {
        type = types.path;
        default = "/var/spool/uucp";
        description = "Spool directory";
      };

      lockDir = mkOption {
        type = types.path;
        default = "/var/spool/uucp";
        description = "Lock directory";
      };

      pubDir = mkOption {
        type = types.path;
        default = "/var/spool/uucppublic";
        description = "Public directory";
      };

      logFile = mkOption {
        type = types.path;
        default = "/var/log/uucp";
        description = "Log file";
      };

      statFile = mkOption {
        type = types.path;
        default = "/var/log/uucp.stat";
        description = "Statistics file";
      };

      debugFile = mkOption {
        type = types.path;
        default = "/var/log/uucp.debug";
        description = "Debug file";
      };

      interval = mkOption {
        type = types.nullOr types.str;
        default = "1h";
        description = ''
          Specification of when to run `uucico' in format used by systemd timers
          The default is to do so every hour
        '';
      };

      extraConfig = mkOption {
        type = types.str;
        default = ''
          run-uuxqt 1
        '';
        description = "Extra configuration to append verbatim to `/etc/uucp/config'";
      };

      extraSys = mkOption {
        type = types.str;
        default = ''
          protocol-parameter g packet-size 4096
        '';
        description = "Extra configuration to prepend verbatim to `/etc/uucp/sys`";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      environment.etc."uucp/config" = {
        text = ''
          hostname ${cfg.nodeName}

          spool ${cfg.spoolDir}
          lockdir ${cfg.lockDir}
          pubdir ${cfg.pubDir}
          logfile ${cfg.logFile}
          statfile ${cfg.statFile}
          debugfile ${cfg.debugFile}

          ${cfg.extraConfig}
        '';
      };

      users.users."uucp" = {
        name = "uucp";
        isSystemUser = true;
        isNormalUser = false;
        createHome = true;
        home = cfg.spoolDir;
        description = "User for uucp over ssh";
        useDefaultShell = true;
        group = "uucp";
      } // cfg.sshUser;

      users.groups."uucp" = {};

      system.activationScripts."uucp-logs" = ''
        mkdir -p $(dirname "${cfg.logFile}")
        mkdir -p $(dirname "${cfg.statFile}")
        mkdir -p $(dirname "${cfg.debugFile}")
        mkdir -p "${cfg.spoolDir}"
        touch ${cfg.logFile}
        chown ${config.users.users."uucp".name}:${config.users.users."uucp".group} ${cfg.logFile}
        chmod 644 ${cfg.logFile}
        touch ${cfg.statFile}
        chown ${config.users.users."uucp".name}:${config.users.users."uucp".group} ${cfg.statFile}
        chmod 644 ${cfg.statFile}
        touch ${cfg.debugFile}
        chown ${config.users.users."uucp".name}:${config.users.users."uucp".group} ${cfg.debugFile}
        chmod 644 ${cfg.debugFile}
      '';

      environment.etc."uucp/port" = {
        text = ''
          port ssh
          type stdin
          protocol e
        '' + concatStringsSep "\n" (map portSpec cfg.remoteNodes);
      };
      environment.etc."uucp/sys" = {
        text = cfg.extraSys + "\n" + concatStringsSep "\n" (map sysSpec cfg.remoteNodes);
      };

      security.wrappers = let
        wrapper = p: { name = p;
                       value = {
                         source = "${pkgs.uucp config.security.wrapperDir}/bin/${p}";
                         owner = "root";
                         group = "root";
                         setuid = true;
                         setgid = false;
                       };
                     };
      in listToAttrs (map wrapper ["uucico" "uuxqt" "cu" "uucp" "uuname" "uustat" "uux"]);

      environment.systemPackages = with pkgs; [
        (uucp config.security.wrapperDir) (rmail config.security.wrapperDir)
      ];
    })
    (mkIf (cfg.interval != null) {
      systemd.services."uucico@" = {
        serviceConfig = {
          User = "uucp";
          Type = "oneshot";
          ExecStart = "${config.security.wrapperDir}/uucico -D -S %i";
        };
      };

      systemd.timers."uucico@" = {
        timerConfig.OnActiveSec = cfg.interval;
        timerConfig.OnUnitActiveSec = cfg.interval;
        timerConfig.RandomizedDelaySec = 30;
      };

      systemd.targets."multi-user" = {
        wants = map (name: "uucico@${name}.timer") cfg.remoteNodes;
      };
    })
  ];
}
