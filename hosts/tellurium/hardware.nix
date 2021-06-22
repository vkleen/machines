{ pkgs, lib, ... }:
{
  boot.wipeRoot = true;

# cryptsetup:
#   cryptsetup luksFormat /dev/sda1 --cipher='capi:adiantum(xchacha20,aes)-plain64' --key-size=256 --keyslot-key-size=512 --keyslot-cipher=aes-xts-plain64 --pbkdf=argon2i --hash=blake2b512 --sector-size=4096 --align-payload=2048
#   cryptsetup luksFormat /dev/sda2 --cipher='capi:adiantum(xchacha20,aes)-plain64' --key-size=256 --keyslot-key-size=512 --keyslot-cipher=aes-xts-plain64 --pbkdf=argon2i --hash=blake2b512 --sector-size=4096 --align-payload=2048
#   cryptsetup luksAddKey /dev/sda1 /persist/private/keyfiles/swap
#   cryptsetup luksAddKey /dev/sda2 /persist/private/keyfiles/data
#
# ZFS formatting:
#   zpool create -o ashift=12 -O mountpoint=none boron /dev/mapper/tellurium-data
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off tellurium/local/root
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off tellurium/local/nix
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off tellurium/safe/home
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off tellurium/safe/persist
#   zfs create -o refreservation=1G -o mountpoint=none tellurium/local/reserved

#   zfs set com.sun:auto-snapshot=true boron/safe
  boot.initrd.kernelModules = [ "nvme" "mmc_block" "mmc_spi" "spi_sifive" "spi_nor" "xhci_hcd" ];
  hardware.deviceTree.name = "sifive/hifive-unmatched-a00.dtb";

  boot.initrd.luks = {
    devices = {
      "tellurium-swap" = {
        device = "/dev/disk/by-uuid/26bbe54d-7c19-4cd9-9448-609d77d1814e";
        keyFile = "/persist/private/keyfiles/swap";
      };
      "tellurium-data" = {
        device = "/dev/disk/by-uuid/ad7123e8-445b-4354-8294-6fbd45bec37d";
        keyFile = "/persist/private/keyfiles/data";
      };
    };
    cryptoModules = [
      "nhpoly1305" "chacha_generic" "libchacha" "adiantum" "libpoly1305"
    ];
  };

  boot.initrd.secrets = {
    "/persist/private/keyfiles/swap" = null;
    "/persist/private/keyfiles/data" = null;
  };
  boot.loader.supportsInitrdSecrets = true;

  hardware.enableRedistributableFirmware = true;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  system.build.installBootloader = lib.mkForce false;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    enableUnstable = true;
    forceImportRoot = false;
    forceImportAll = false;
  };

  fileSystems."/" = {
    device = "tellurium/local/root";
    fsType = "zfs";
  };
  fileSystems."/nix" = {
    device = "tellurium/local/nix";
    fsType = "zfs";
  };
  fileSystems."/persist" = {
    device = "tellurium/safe/persist";
    fsType = "zfs";
  };
  fileSystems."/home" = {
    device = "tellurium/safe/home";
    fsType = "zfs";
  };

  swapDevices = [
    { device = "/dev/mapper/tellurium-swap"; }
  ];
}
