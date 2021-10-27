{ config, lib, pkgs, ... }:

with lib;

let
  portSpec = name: ''
    port ${name}
    type pipe
    protocol ${if builtins.hasAttr name cfg.protocols then cfg.protocols."${name}" else cfg.defaultProtocol}
    reliable true
    command ${pkgs.openssh}/bin/ssh -x -o batchmode=yes ${name}
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
          If enabled we set up an account accessible via uucp over ssh
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

      remoteNodes = mkOption {
        type = types.listOf types.str;
        default = {};
        description = ''
          Ports to set up
          Names will probably need to be configured in sshConfig
        '';
      };

      commandPath = mkOption {
        type = types.listOf types.path;
        default = [ "${pkgs.rmail}/bin" ];
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

  config = mkIf cfg.enable {
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
    } // cfg.sshUser;

    system.activationScripts."uucp-sshconfig" = ''
      mkdir -p ${config.users.users."uucp".home}/.ssh
      chown ${config.users.users."uucp".name}:${config.users.users."uucp".group} ${config.users.users."uucp".home}/.ssh
      chmod 700 ${config.users.users."uucp".home}/.ssh
      ln -fs ${builtins.toFile "ssh-config" cfg.sshConfig} ${config.users.users."uucp".home}/.ssh/config
    '';

    system.activationScripts."uucp-logs" = ''
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

    # environment.etc."uucp/port" = {
    #   text = ''
    #     port ssh
    #     type stdin
    #     protocol e
    #   '' + concatStringsSep "\n" (map portSpec cfg.remoteNodes);
    # };
    environment.etc."uucp/sys" = {
      text = cfg.extraSys + "\n" + concatStringsSep "\n" (map sysSpec cfg.remoteNodes);
    };

    security.wrappers = let
      wrapper = p: { name = p;
                     value = {
                       source = "${pkgs.uucp}/bin/${p}";
                       owner = "root";
                       group = "root";
                       setuid = true;
                       setgid = false;
                     };
                   };
    in listToAttrs (map wrapper ["uucico" "uuxqt" "cu" "uucp" "uuname" "uustat" "uux"]);

    environment.systemPackages = with pkgs; [
      uucp rmail
    ];
  };
}
