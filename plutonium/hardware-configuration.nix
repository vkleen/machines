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
    device = "nodev";
    copyKernels = true;
    fsIdentifier = "label";
    extraConfig = "serial; terminal_input serial; terminal_output serial";
  };

  boot.kernelParams = [ "console=ttyS0" ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = [ "discard" "relatime" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];
}
