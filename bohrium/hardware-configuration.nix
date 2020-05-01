{ config, lib, pkgs, ... }:

{
  imports = [];

  hardware.enableRedistributableFirmware = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "kvm-intel" "dm_snapshot" "dm_integrity" ];
  boot.extraModulePackages = [ ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    enableUnstable = true;
    forceImportRoot = false;
    forceImportAll = false;
  };

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    version = 2;
    efiSupport = true;
    enableCryptodisk = true;
    copyKernels = true;
    extraInitrd = "/boot/keyfiles.gz";
    extraPrepareConfig = ''
      umask 277
      ${pkgs.coreutils}/bin/sort | ${pkgs.cpio}/bin/cpio -o -H newc -R +0:+0 --reproducible | ${pkgs.gzip}/bin/gzip -9 > @bootPath@/keyfiles.gz <<EOF
/persist/private/keyfiles/swap
/persist/private/keyfiles/data
/persist/private/keyfiles/boot
/persist/private/keyfiles/zfs
      EOF
    '';
  };

# cryptsetup:
#   cryptsetup luksFormat /dev/nvme0n1p2 --cipher='capi:xts(aes)-plain64' --key-size=512 --keyslot-key-size=512 --keyslot-cipher=aes-xts-plain64 --hash=sha256 --type luks
#   cryptsetup luksFormat /dev/nvme0n1p3 --cipher='capi:adiantum(xchacha20,aes)-plain64' --key-size=256 --keyslot-key-size=512 --keyslot-cipher=aes-xts-plain64 --pbkdf=argon2i --hash=blake2b512 --sector-size=4096
#   cryptsetup luksFormat /dev/nvme0n1p4 --cipher='capi:adiantum(xchacha20,aes)-plain64' --key-size=256 --keyslot-key-size=512 --keyslot-cipher=aes-xts-plain64 --pbkdf=argon2i --hash=blake2b512 --sector-size=4096
#
# ZFS formatting:
#   zpool create -o ashift=12 -O encryption=aes-256-ccm -O keyformat=passphrase -O keylocation=file:///persist/private/zfs -O mountpoint=none bohrium /dev/mapper/bohrium-data
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off bohrium/local/root
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off -o compression=lz4 bohrium/local/nix
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off -o compression=lz4 bohrium/safe/home
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off -o compression=lz4 bohrium/safe/persist
#   zfs create -o refreservation=1G -o mountpoint=none bohrium/local/reserved

#   zfs set com.sun:auto-snapshot=true bohrium/safe

  boot.initrd.luks = {
    devices = {
      "bohrium-swap" = {
        device = "/dev/disk/by-uuid/f3f36a73-398e-4bdd-9db2-df0b2ae118a2";
        keyFile = "/persist/private/keyfiles/swap";
      };
      "bohrium-data" = {
        device = "/dev/disk/by-uuid/e4628d1c-659f-47ce-8fcd-cbb8a8e201be";
        keyFile = "/persist/private/keyfiles/data";
      };
      "bohrium-boot" = {
        device = "/dev/disk/by-uuid/a1e2190b-557c-4b94-852a-d855f326b72f";
        keyFile = "/persist/private/keyfiles/boot";
      };
    };
    cryptoModules = [
      "dm_integrity" "aes" "aes_generic" "aes_x86_64"  "sha256"
      "aegis128" "aegis128_aesni"
      "dm_bufio" "algif_aead" "algif_skcipher" "algif_hash" "authenc"
    ];
  };

  fileSystems."/" = {
    device = "bohrium/local/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "bohrium/local/nix";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "bohrium/safe/home";
    fsType = "zfs";
  };

  fileSystems."/persist" = {
    device = "bohrium/safe/persist";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/de25fe4d-e6d0-4f1e-9eb4-89f19bd51009";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/68DD-25F9";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/mapper/bohrium-swap"; }
  ];

}
