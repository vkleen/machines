{ config, lib, pkgs, ... }:

{
  imports =
    [
    ];

  boot.initrd.availableKernelModules = [ "nvme" "aacraid" "xhci_pci" "sd_mod" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/nvme0n1p1";
      fsType = "ext4";
    };

  swapDevices = [ ];
}
