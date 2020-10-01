{ pkgs, lib, config, ... }:
{
  options = {
    boot.wipeRoot = lib.mkEnableOption "Wipe root fs on boot with specified persistent parts";
  };
  config = lib.mkIf config.boot.wipeRoot {
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      ${pkgs.zfs}/bin/zfs rollback -r bohrium/local/root@blank
    '';

    fileSystems."/var/lib/iwd" = {
      device = "/persist/iwd";
      options = [ "bind" ];
    };

    fileSystems."/root/.aws" = {
      device = "/persist/aws";
      options = [ "bind" ];
    };
  };
}
