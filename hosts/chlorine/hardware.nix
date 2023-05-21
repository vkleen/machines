{ pkgs, lib, ... }:
{
  system.build.installBootloader = lib.mkForce false;
  boot.loader.grub.enable = false;

  boot.kernelParams = [ "console=hvc0" ];
  hardware.opengl = {
    enable = true;
    extraPackages = [
      pkgs.rocm-opencl-icd
      pkgs.rocm-opencl-runtime
      pkgs.hip
    ];
  };

  boot.kernelPatches = [
    {
      name = "chlorine-amdkfd-numa-hack-6.1";
      patch = ./chlorine-amdkfd-numa-hack-6.1.patch;
    }
    {
      name = "debug-enable";
      patch = null;
      extraConfig = ''
        EXPERT y
        KERNEL_DEBUG y
      '';
    }
  ];

  boot.kernelModules = [ "dm_snapshot" "dm_integrity" "powernv-cpufreq" ];
  powerManagement.cpuFreqGovernor = "schedutil";

  boot.initrd.availableKernelModules = [
    "nvme"
  ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks = {
    devices = {
      "chlorine_pv" = {
        device = "/dev/disk/by-uuid/6939b21d-b466-4b00-b79f-cee0ad92efd1";
      };
    };
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/978e4c7d-a137-469e-9fab-b202d02f11c1";
      fsType = "ext4";
    };

  swapDevices = [ ];

  hardware.firmware = [
    pkgs.firmwareLinuxNonfree
  ];
}
