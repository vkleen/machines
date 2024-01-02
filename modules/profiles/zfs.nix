{ pkgs, ... }:
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
