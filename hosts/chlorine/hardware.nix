{pkgs, lib, ...}:
{
  boot.wipeRoot = false;

  system.boot.loader.kernelFile = "vmlinux";
  system.build.installBootloader = lib.mkForce false;
  boot.loader.grub.enable = false;

  boot.kernelParams = [ "console=hvc0" ];
  hardware.opengl = {
    enable = true;
    extraPackages = []; #with pkgs; [ rocm-opencl-icd ];
  };

  boot.kernelModules = [ "dm_snapshot" "dm_integrity" "powernv-cpufreq" ];
  powerManagement.cpuFreqGovernor = "schedutil";

  boot.initrd.includeDefaultModules = false;
  boot.initrd.availableKernelModules = [
    "nvme" "aacraid" "xhci_pci" "sd_mod"
    "dm_mod"
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
    { device = "/dev/disk/by-uuid/978e4c7d-a137-469e-9fab-b202d02f11c1";
      fsType = "ext4";
    };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    algorithm = "zstd";
  };
  swapDevices = [ ];

  hardware.firmware = [
    pkgs.firmwareLinuxNonfree
  ];
}
