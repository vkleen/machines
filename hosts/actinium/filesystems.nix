{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.profiles.initrd-all-crypto-modules
  ];

  boot.wipeRoot = {
    enable = true;
    method = "btrfs";
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];

  boot.initrd.luks = {
    devices = {
      "sd" = {
        device = "/dev/disk/by-uuid/c6e87e76-7bbe-4c18-b74f-60e7c7c25170";
      };
    };
  };

  fileSystems."/" =
    {
      device = "/dev/mapper/sd";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/persist" = {
    device = "/dev/mapper/sd";
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "subvol=persist" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/sd";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  swapDevices = [ ];
}
