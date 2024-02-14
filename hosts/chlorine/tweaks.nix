{ lib, ... }:
{
  system.build.installBootloader = lib.mkForce false;
  boot.loader.grub.enable = false;

  boot.kernelParams = [ "console=hvc0" ];

  boot.kernelModules = [ "dm_snapshot" "dm_integrity" "powernv-cpufreq" ];
  powerManagement.cpuFreqGovernor = "schedutil";

  boot.initrd.availableKernelModules = [
    "nvme"
  ];

  boot.wipeRoot = lib.mkForce false;

  services.fwupd.enable = lib.mkForce false;
}
