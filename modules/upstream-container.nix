{ pkgs, config, lib, flake, ... }:
let
  cfg = config.virtualisation.upstream-container;

  bindMountOpts = { name, ... }: {
    options = {
      mountPoint = lib.mkOption {
        example = "/mnt/usb";
        type = lib.types.str;
        description = "Mount point on the container file system.";
      };
      hostPath = lib.mkOption {
        default = null;
        example = "/home/alice";
        type = lib.types.nullOr lib.types.str;
        description = "Location of the host path to be mounted.";
      };
      isReadOnly = lib.mkOption {
        default = true;
        type = lib.types.bool;
        description = "Determine whether the mounted path will be accessed in read-only mode.";
      };
    };
    config = {
      mountPoint = lib.mkDefault name;
    };
  };

  allowedDeviceOpts = { ... }: {
    options = {
      node = lib.mkOption {
        example = "/dev/net/tun";
        type = lib.types.str;
        description = "Path to device node";
      };
      modifier = lib.mkOption {
        example = "rw";
        type = lib.types.str;
        description = ''
          Device node access modifier. Takes a combination
          <literal>r</literal> (read), <literal>w</literal> (write), and
          <literal>m</literal> (mknod). See the
          <literal>systemd.resource-control(5)</literal> man page for more
          information.'';
      };
    };
  };

  mkBindFlag = d:
    let flagPrefix = if d.isReadOnly then " --bind-ro=" else " --bind=";
        mountstr = if d.hostPath != null then "${d.hostPath}:${d.mountPoint}" else "${d.mountPoint}";
    in flagPrefix + mountstr;

  mkBindFlags = bs: lib.concatMapStrings mkBindFlag (lib.attrValues bs);

  containerInit = pkgs.writeScript "container-init" ''
    #!${pkgs.runtimeShell} -e
    exec "$1"
  '';
  preStartScript = ''
    ${cfg.preStartScript}
  '';
  postStartScript = "";
  postStopScript = ''
    ${cfg.postStopScript}
  '';
  startScript = ''
    mkdir -p -m 0755 "$root/etc" "$root/var/lib"
    mkdir -p -m 0700 "$root/var/lib/private" "$root/root" /run/containers
    if ! [ -e "$root/etc/os-release" ]; then
      touch "$root/etc/os-release"
    fi

    if ! [ -e "$root/etc/machine-id" ]; then
      touch "$root/etc/machine-id"
    fi

    mkdir -p -m 0755 \
      "/nix/var/nix/profiles/per-container/$INSTANCE" \
      "/nix/var/nix/gcroots/per-container/$INSTANCE"

    # Run systemd-nspawn without startup notification (we'll
    # wait for the container systemd to signal readiness).
    exec ${config.systemd.package}/bin/systemd-nspawn \
      --keep-unit \
      -M "upstream" -D "$root" \
      --notify-ready=yes \
      --bind-ro=/nix/store \
      --bind-ro=/nix/var/nix/db \
      --bind-ro=/nix/var/nix/daemon-socket \
      --bind="/nix/var/nix/profiles/per-container/$INSTANCE:/nix/var/nix/profiles" \
      --bind="/nix/var/nix/gcroots/per-container/$INSTANCE:/nix/var/nix/gcroots" \
      $EXTRA_NSPAWN_FLAGS \
      --setenv PATH="$PATH" \
      --capability=CAP_SYS_TTY_CONFIG,CAP_NET_ADMIN,CAP_NET_RAW,CAP_SYS_ADMIN \
      --ephemeral \
      --network-namespace-path=/run/netns/${cfg.netns} \
      ${containerInit} "${cfg.config.system.build.toplevel}/init"
  '';

  serviceDirectives = {
    SyslogIdentifier = "container upstream";
    Type = "notify";

    RestartForceExitStatus = "133";
    SuccessExitStatus = "133";

    Restart = "no";

    DevicePolicy = "closed";
    DeviceAllow = map (d: "${d.node} ${d.modifier}") cfg.allowedDevices;

    RuntimeDirectory = [ "containers/upstream" ];
  };
  unitDirectives = {
    ConditionCapability = ["CAP_SYS_TTY_CONFIG" "CAP_NET_ADMIN" "CAP_NET_RAW" "CAP_SYS_ADMIN"];
  };
in {
  options = {
    virtualisation.upstream-container = {
      enable = lib.mkEnableOption "upstream-container";
      config =  lib.mkOption {
        description = ''
          A specification of the desired configuration of this
          container, as a NixOS module.
        '';
        type = let
          confPkgs = if config.pkgs == null then pkgs else config.pkgs;
        in lib.mkOptionType {
          name = "Toplevel NixOS config";
          merge = loc: defs: (import (pkgs.path + "/nixos/lib/eval-config.nix") {
            inherit (config.nixpkgs.localSystem) system;
            inherit pkgs;
            baseModules = import (pkgs.path + "/nixos/modules/module-list.nix");
            inherit (pkgs) lib;
            modules =
              let
                extraConfig = {
                  _file = "module at ${__curPos.file}:${toString __curPos.line}";
                  config = {
                    boot.isContainer = true;
                    networking.hostName = lib.mkDefault "upstream";
                  };
                };
              in [ extraConfig ] ++ (map (x: x.value) defs);
            prefix = [ "containers" "upstream" ];
          }).config;
        };
      };
      netns = lib.mkOption {
        example = "upstream";
        type = lib.types.str;
        description = "Name of network namespace to put the container in.";
      };
      preStartScript = lib.mkOption {
        type = lib.types.str;
        description = "Prestart script";
      };
      postStopScript = lib.mkOption {
        type = lib.types.str;
        description = "Poststop script";
      };
      bindMounts = lib.mkOption {
        type = with lib.types; attrsOf (submodule bindMountOpts);
        default = {};
        example = lib.literalExample ''
          { "/home" = { hostPath = "/home/alice";
                        isReadOnly = false; };
          }
        '';

        description =
          ''
            An extra list of directories that is bound to the container.
          '';
      };
      allowedDevices = lib.mkOption {
        type = with lib.types; listOf (submodule allowedDeviceOpts);
        default = [];
        example = [ { node = "/dev/net/tun"; modifier = "rw"; } ];
        description = ''
          A list of device nodes to which the containers has access to.
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    networking.namespaces.enable = true;

    systemd.services."upstream-container" = {
      description = "Container handling upstream networking";
      after = [ "network-pre.target" "systemd-udevd.service" "systemd-sysctl.service" "netns@${cfg.netns}.service" ];
      bindsTo = [ "netns@${cfg.netns}.service" ];
      before = [ "network.target" "shutdown.target" ];
      wants = [ "network.target" ];
      conflicts = [ "shutdown.target" ];
      wantedBy = [ "multi-user.target" "network-online.target" ];

      environment = {
        root = "/run/containers/upstream";
        EXTRA_NSPAWN_FLAGS = "${mkBindFlags cfg.bindMounts}";
      };
      path = [ pkgs.iproute pkgs.iptables ];

      preStart = preStartScript;
      script = startScript;
      postStart = postStartScript;
      postStop = postStopScript;
      serviceConfig = serviceDirectives;
      unitConfig = unitDirectives;
    };
  };
}
