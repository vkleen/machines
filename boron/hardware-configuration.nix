{ config, lib, pkgs, ... }:

{
# cryptsetup:
#   cryptsetup luksFormat /dev/sda1 --cipher='capi:adiantum(xchacha20,aes)-plain64' --key-size=256 --keyslot-key-size=512 --keyslot-cipher=aes-xts-plain64 --pbkdf=argon2i --hash=blake2b512 --sector-size=4096
#   cryptsetup luksFormat /dev/sda2 --cipher='capi:adiantum(xchacha20,aes)-plain64' --key-size=256 --keyslot-key-size=512 --keyslot-cipher=aes-xts-plain64 --pbkdf=argon2i --hash=blake2b512 --sector-size=4096
#   cryptsetup luksFormat /dev/sda3 --cipher='capi:adiantum(xchacha20,aes)-plain64' --key-size=256 --keyslot-key-size=512 --keyslot-cipher=aes-xts-plain64 --pbkdf=argon2i --hash=blake2b512

#   cryptsetup luksAddKey /dev/sda1 /persist/private/keyfiles/boot
#   cryptsetup luksAddKey /dev/sda2 /persist/private/keyfiles/swap
#   cryptsetup luksAddKey /dev/sda3 /persist/private/keyfiles/data
#
# ZFS formatting:
#   zpool create -o ashift=12 -O mountpoint=none boron /dev/mapper/boron-data
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off boron/local/root
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off boron/local/nix
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off boron/safe/home
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off boron/safe/persist
#   zfs create -o refreservation=1G -o mountpoint=none boron/local/reserved

#   zfs set com.sun:auto-snapshot=true boron/safe

  # boot.initrd.luks = {
  #   devices = {
  #     "boron-swap" = {
  #       device = "/dev/disk/by-uuid/4f73660a-19ed-4332-9971-598e1a0b95bc";
  #       keyFile = "/persist/private/keyfiles/swap";
  #     };
  #     "boron-boot" = {
  #       device = "/dev/disk/by-uuid/1e822538-445a-4a45-9265-593a7ed8ee74";
  #       keyFile = "/persist/private/keyfiles/boot";
  #     };
  #     "boron-data" = {
  #       device = "/dev/disk/by-uuid/89c03c30-fa6a-4964-a2b7-9f52cd4af180";
  #       keyFile = "/persist/private/keyfiles/data";
  #     };
  #   };
  #   cryptoModules = [
  #     "dm_integrity" "aes" "aesni_intel" "sha256"
  #     "adiantum" "nhpoly1305_avx2" "curve25519_x86_64" "chacha_x86_64" "poly1305_x86_64" "blake2s_x86_64"
  #     "dm_bufio" "algif_aead" "algif_skcipher" "algif_hash" "authenc"
  #   ];
  # };

  hardware.enableRedistributableFirmware = true;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  system.build.installBootloader = lib.mkForce false;

  fileSystems."/" = {
    device = "/dev/mmcblk1p2";
  };

  # fileSystems."/" = {
  #   device = "boron/local/root";
  #   fsType = "zfs";
  # };
  # fileSystems."/nix" = {
  #   device = "boron/local/nix";
  #   fsType = "zfs";
  # };
  # fileSystems."/persist" = {
  #   device = "boron/safe/persist";
  #   fsType = "zfs";
  # };
  # fileSystems."/home" = {
  #   device = "boron/safe/home";
  #   fsType = "zfs";
  # };
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/1b681f88-3e45-4a61-8daf-f5b739e72b76";
  #   fsType = "ext4";
  # };

  # swapDevices = [
  #   { device = "/dev/mapper/boron-swap"; }
  # ];
}
