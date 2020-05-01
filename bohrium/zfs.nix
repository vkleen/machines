{ config, pkgs, lib, ... }:
{
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 4;
    hourly = 24;
    daily = 7;
    monthly = 1;
  };
}
