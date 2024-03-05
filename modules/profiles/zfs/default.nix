{ pkgs, lib, trilby, ... }:
{
  config = lib.mkMerge [
    {
      services.zfs.zed.settings = {
        ZED_EMAIL_PROG = "${pkgs.coreutils}/bin/true";
      };

      boot.kernelPackages = pkgs.zfsUnstable.latestCompatibleLinuxPackages;

      boot.supportedFilesystems = [ "zfs" ];
      boot.zfs = {
        package = pkgs.zfs_unstable;
        forceImportRoot = false;
        forceImportAll = false;
      };

      services.zfs.autoSnapshot = {
        enable = true;
        flags = "-p --utc";
        frequent = 4;
        hourly = 24;
        daily = 7;
        monthly = 1;
      };
    }
    (lib.mkIf (trilby.hostSystem.cpu.name == "powerpc64le") {
      boot.zfs.removeLinuxDRM = true;
      boot.kernelPackages = lib.mkOverride 99 ((pkgs.zfs_unstable.override {
        removeLinuxDRM = true;
      }).latestCompatibleLinuxPackages.extend (kfinal: kprev: {
        zfs_unstable = kprev.zfs_unstable.overrideAttrs (o: {
          patches = o.patches or [ ] ++ [ ./zfs-license.patch ];
        });
      }));
    })
  ];
}
