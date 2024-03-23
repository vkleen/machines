{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.profiles.initrd-all-crypto-modules
  ];

  boot.wipeRoot = {
    enable = true;
    method = "btrfs";
  };

  boot.initrd.availableKernelModules = [ "nvme" ];

  boot.initrd.luks = {
    devices = {
      "nvme" = {
        device = "/dev/disk/by-uuid/07adb47b-ed2f-47d0-81c0-d842185b61c8";
      };
    };
  };

  fileSystems."/" =
    {
      device = "/dev/mapper/nvme";
      fsType = "btrfs";
      options = [ "compress=zstd,subvol=root" ];
    };

  fileSystems."/persist" = {
    device = "/dev/mapper/nvme";
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "compress=zstd,subvol=persist" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/nvme";
    fsType = "btrfs";
    options = [ "compress=zstd,noatime,subvol=nix" ];
  };

  swapDevices = [ ];
}
