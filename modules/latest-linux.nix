{ pkgs, system, ... }:
let
  kernelPackages = pkgs.zfsUnstable.latestCompatibleLinuxPackages;
in
{
  boot.kernelPackages =
    if system.hostCpu == "powerpc64le"
    then pkgs.mkPower9LinuxPackages kernelPackages
    else kernelPackages;
}
