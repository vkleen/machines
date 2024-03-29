{ pkgs, config, lib, ... }:
let cfg = config.networking.namespaces;
in {
  options = {
    networking.namespaces = {
      enable = lib.mkEnableOption "Enable netns@ service template";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services."netns@" = {
      description = "%I network namspace";
      before = [ "network-pre.target" ];
      wants = [ "network-pre.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        PrivateNetwork = true;
        ExecStart = "${pkgs.writers.writeDash "netns-up" ''
          ${pkgs.iproute2}/bin/ip netns add "$1"
          ${pkgs.util-linux}/bin/umount /var/run/netns/"$1"
          ${pkgs.util-linux}/bin/mount --bind /proc/self/ns/net /var/run/netns/"$1"
        ''} %I";
        ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
      };
    };
  };
}
