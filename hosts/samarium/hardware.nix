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
    device = "/dev/sda";
  };

  fileSystems."/" =
    { device = "/dev/sda3";
      fsType = "ext4";
      options = [ "discard" "relatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/sda1";
      fsType = "ext2";
    };

  swapDevices =
    [ { device = "/dev/sda2"; }
    ];
}
