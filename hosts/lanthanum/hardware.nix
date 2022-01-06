{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ ];
  boot.initrd.supportedFilesystems = [ "ext4" ];
  boot.initrd.kernelModules = [ "virtio_scsi" "virtio_blk" "virtio_pci" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  hardware.enableRedistributableFirmware = true;

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
    copyKernels = true;
    fsIdentifier = "label";
  };

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = [ "discard" "relatime" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];
}
