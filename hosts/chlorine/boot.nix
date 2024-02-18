{ inputs, lib, ... }:
{
  imports = [
    inputs.self.nixosModules.profiles.initrd-all-crypto-modules
  ];
  config = {
    boot.kernelParams = [ "console=hvc0" ];

    boot.wipeRoot = lib.mkForce false;

    system.build.installBootloader = lib.mkForce false;
    boot.loader.grub.enable = false;

    boot.kernelModules = [ "dm_snapshot" "dm_integrity" "powernv-cpufreq" ];
    powerManagement.cpuFreqGovernor = "schedutil";

    boot.initrd.availableKernelModules = [
      "nvme"
    ];
  };
}
