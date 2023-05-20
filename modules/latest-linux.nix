{ pkgs, system, ... }:
let
  kernelPackages = pkgs.zfsUnstable.latestCompatibleLinuxPackages;
in
{
  boot.kernelPackages =
    if system.hostPlatform == "powerpc64le-linux"
    then pkgs.mkPower9LinuxPackages kernelPackages
    else kernelPackages;
}
