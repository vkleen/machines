{ config, lib, pkgs, ... }:

{
  imports =
    [
    ];

  boot.initrd.availableKernelModules = [ "nvme" "aacraid" "xhci_pci" "sd_mod" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/nvme0n1";
      fsType = "btrfs";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 144;
}
