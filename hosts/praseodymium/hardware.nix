{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ ];
  boot.initrd.supportedFilesystems = [ "ext4" ];
  boot.initrd.kernelModules = [ "vmw_pvscsi" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  hardware.enableRedistributableFirmware = true;

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    copyKernels = true;
    fsIdentifier = "label";
  };

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = [ "discard" "relatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "ext4";
      options = [ "discard" "relatime" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];
}
