{ config, pkgs, ... }:
{
  system.extra-profiles = [ "docker" ];
  virtualisation.docker = {
    enable = true;
    extraOptions = "--storage-driver=vfs";
  };
}
