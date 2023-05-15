{ pkgs, system, inputs, ... }:
let
  # kernelPackages = pkgs.zfsUnstable.latestCompatibleLinuxPackages;
  # kernelPackages = pkgs.linuxPackages_latest;
  debug_linux =
    pkgs.buildLinux {
      version = "6.3.0-debug";
      modDirVersion = "6.3.0";

      src = inputs.debug-linux;

      kernelPatches = [ ];
      extraMeta.branch = "6.3";
    };
  kernelPackages = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor debug_linux);
in
{
  boot.kernelPackages =
    if system.hostPlatform == "powerpc64le-linux"
    then pkgs.mkPower9LinuxPackages kernelPackages
    else kernelPackages;
}
