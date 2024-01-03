{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.profiles.initrd-all-crypto-modules
  ];
  config = {
    boot.wipeRoot = true;

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ "kvm-intel" ];

    boot.loader.supportsInitrdSecrets = true;

    boot.loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      enableCryptodisk = true;
      copyKernels = true;
    };
  };
}
