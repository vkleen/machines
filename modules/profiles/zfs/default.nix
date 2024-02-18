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
        enableUnstable = true;
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
      boot.kernelPackages = lib.mkOverride 99 ((pkgs.zfsUnstable.override {
        removeLinuxDRM = true;
      }).latestCompatibleLinuxPackages.extend (kfinal: kprev: {
        zfsUnstable = kprev.zfsUnstable.overrideAttrs (o: {
          patches = o.patches or [ ] ++ [ ./zfs-license.patch ];
        });
      }));
    })
  ];
}
