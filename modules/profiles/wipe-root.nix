{ lib, config, trilby, pkgs, inputs, ... }:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  options = {
    boot.wipeRoot = lib.mkEnableOption "Wipe root fs on boot with specified persistent parts" // { default = true; };
  };
  config = lib.mkIf config.boot.wipeRoot {
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      ${pkgs.zfs}/bin/zfs rollback -r ${trilby.name}/local/root@blank
    '';

    fileSystems."/persist".neededForBoot = true;

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/systemd/coredump"
      ];
    };
  };
}
