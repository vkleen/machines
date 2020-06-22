{ config, pkgs, lib, ... }:
{
  services.zfs.zed.settings = {
    ZED_EMAIL_PROG = "${pkgs.coreutils}/bin/true";
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
