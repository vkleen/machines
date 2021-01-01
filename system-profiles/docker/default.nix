{ config, pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    extraOptions = "--storage-driver=vfs";
  };
}
