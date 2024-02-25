{ lib, config, trilby, pkgs, inputs, ... }:
let
  cfg = config.boot.wipeRoot;
  rootDev = config.fileSystems."/".device;
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  options = {
    boot.wipeRoot = {
      enable = lib.mkEnableOption "Wipe root fs on boot with specified persistent parts";
      method = lib.mkOption {
        type = lib.types.enum [ "zfs" "btrfs" ];
        default = "zfs";
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.method == "zfs") {
      boot.initrd.postDeviceCommands = lib.mkAfter ''
        ${pkgs.zfs}/bin/zfs rollback -r ${trilby.name}/local/root@blank
      '';
    })
    (lib.mkIf (cfg.enable && cfg.method == "btrfs") {
      boot.initrd.postDeviceCommands = lib.mkAfter ''
        mkdir /btrfs_tmp
        mount ${rootDev} /btrfs_tmp
        if [[ -e /btrfs_tmp/root ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
        }

        for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
            delete_subvolume_recursively "$i"
        done

        btrfs subvolume create /btrfs_tmp/root
        umount /btrfs_tmp
      '';
    })
    (lib.mkIf cfg.enable {
      fileSystems."/persist".neededForBoot = true;

      environment.persistence."/persist" = {
        hideMounts = true;
        directories = [
          "/var/log"
          "/var/lib/systemd/coredump"
        ];
      };
    })
  ];
}
