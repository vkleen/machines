{ inputs, lib, ... }:
{
  imports = [
    inputs.self.nixosModules.profiles.initrd-all-crypto-modules
  ];

  boot.wipeRoot = {
    enable = true;
    method = "btrfs-systemd";
  };

  boot.kernelPatches = [
    {
      name = "encrypted_key";
      patch = null;
      extraStructuredConfig = {
        ENCRYPTED_KEYS = lib.kernel.yes;
      };
    }
  ];

  # cryptsetup:
  #   sudo cryptsetup --cipher aes-xts-plain64 --hash blake2b-512 --iter-time 5000 --key-size 256 --pbkdf argon2id --use-urandom luksFormat /dev/nvme0n1p2

  boot.initrd.luks = {
    devices = {
      "nvme" = {
        device = "/dev/disk/by-uuid/55ea9f69-85b1-4887-9a73-e85e26087a5a";
        crypttabExtraOpts = [ "fido2-device=auto" ];
      };
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/bohrium";
    fsType = "btrfs";
    options = [ "subvol=root" "compress=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/bohrium";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/bohrium";
    fsType = "btrfs";
    options = [ "subvol=home" "compress=zstd" ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/bohrium";
    fsType = "btrfs";
    options = [ "subvol=persist" "compress=zstd" ];
  };


  fileSystems."/swap" = {
    device = "/dev/disk/by-label/bohrium";
    fsType = "btrfs";
    options = [ "subvol=swap" ];
  };

  fileSystems."/btrfs" = {
    device = "/dev/disk/by-label/bohrium";
    fsType = "btrfs";
    options = [ "subvolid=5" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };

  swapDevices = [
    #{ device = "/swap/swapfile"; }
  ];

  # services.btrbk = {
  #   instances."snapshot_home" = {
  #     onCalendar = "*:0/15";
  #     settings = {
  #       snapshot_preserve_min = "1w";
  #       snapshot_preserve = "2w";
  #       volume."/btrfs" = {
  #         snapshot_dir = ".snapshots";
  #         subvolume = "home";
  #       };
  #     };
  #   };
  #   instances."snapshot_persist" = {
  #     onCalendar = "*:0/15";
  #     settings = {
  #       snapshot_preserve_min = "1w";
  #       snapshot_preserve = "2w";
  #       volume."/btrfs" = {
  #         snapshot_dir = ".snapshots";
  #         subvolume = "persist";
  #       };
  #     };
  #   };
  # };
  #
  # systemd.tmpfiles.rules = [
  #   "d /btrfs/.snapshots 0755 root root"
  # ];
}
