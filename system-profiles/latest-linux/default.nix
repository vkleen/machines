{ flake, flakeInputs, config, pkgs, lib, ... }:
{
  boot.kernelPackages = pkgs.zfsUnstable.latestCompatibleLinuxPackages;
}
