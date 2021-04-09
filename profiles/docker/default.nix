{ config, pkgs, ... }:
{
  system.extra-profiles = [ "docker" ];
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
    enableOnBoot = false;
  };
}
