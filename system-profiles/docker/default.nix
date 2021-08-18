{ config, pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
    enableOnBoot = false;
  };
}
