{ pkgs, config, lib, ... }:
{
  boot.wipeRoot = true;

  hardware.enableRedistributableFirmware = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "kvm-intel" ];

  boot.initrd.secrets = {
    "/persist/private/keyfiles/swap" = null;
    "/persist/private/keyfiles/data" = null;
    "/persist/private/keyfiles/boot" = null;
    "/persist/private/zfs" = null;
  };
  boot.loader.supportsInitrdSecrets = true;

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    version = 2;
    efiSupport = true;
    enableCryptodisk = true;
    copyKernels = true;
  };

# cryptsetup:
#   cryptsetup luksFormat /dev/nvme0n1p2 --cipher='aes-xts-plain64' --key-size=512 --keyslot-key-size=512 --keyslot-cipher=aes-xts-plain64 --hash=sha256 --type luks
#   cryptsetup luksFormat /dev/nvme0n1p3 --cipher='capi:adiantum(xchacha20,aes)-plain64' --key-size=256 --keyslot-key-size=512 --keyslot-cipher=aes-xts-plain64 --pbkdf=argon2i --hash=blake2b512 --sector-size=4096
#   cryptsetup luksFormat /dev/nvme0n1p4 --cipher='capi:adiantum(xchacha20,aes)-plain64' --key-size=256 --keyslot-key-size=512 --keyslot-cipher=aes-xts-plain64 --pbkdf=argon2i --hash=blake2b512 --sector-size=4096
#   cryptsetup luksAddKey /dev/nvme0n1p2 /persist/private/keyfiles/boot
#   cryptsetup luksAddKey /dev/nvme0n1p3 /persist/private/keyfiles/swap
#   cryptsetup luksAddKey /dev/nvme0n1p4 /persist/private/keyfiles/data
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
        device = "/dev/disk/by-uuid/4e3ff2bf-bdd2-4c43-beae-e16fcc110845";
        keyFile = "/persist/private/keyfiles/boot";
      };
    };

    cryptoModules = [
      "echainiv" "cast_common" "twofish_common" "michael_mic" "crypto_simd"
      "sm4_generic" "ghash-generic" "blake2s_generic" "ecdh_generic" "cast5_generic"
      "serpent_generic" "aes_ti" "camellia_generic" "khazad" "ccm" "gcm"
      "essiv" "authencesn" "sha512_generic" "ecrdsa_generic" "xts" "rmd160"
      "xxhash_generic" "blake2b_generic" "algif_aead" "tpm_key_parser" "asym_tpm"
      "pkcs7_test_key" "zstd" "pcrypt" "deflate" "cmac" "fcrypt" "crc32_generic"
      "sm3_generic" "sha3_generic" "crypto_user" "algif_skcipher" "des_generic"
      "curve25519-generic" "lz4hc" "seqiv" "lz4" "async_tx" "async_memcpy"
      "async_xor" "async_raid6_recov" "async_pq" "tgr192" "seed" "drbg"
      "ansi_cprng" "842" "gf128mul" "crct10dif_common" "rmd128" "jitterentropy_rng"
      "ecb" "adiantum" "cast6_generic" "keywrap" "salsa20_generic" "aegis128"
      "sm2_generic" "algif_rng" "twofish_generic" "lrw" "xor" "crc32c_generic"
      "crypto_engine" "ecc" "vmac" "hmac" "anubis" "algif_hash" "chacha20poly1305"
      "poly1305_generic" "md4" "cbc" "sha256_generic" "authenc" "ctr" "rmd320"
      "xcbc" "cfb" "wp512" "ofb" "nhpoly1305" "streebog_generic" "tea" "cts"
      "rmd256" "pcbc" "aes_generic" "blowfish_common" "cryptd" "blowfish_generic"
      "arc4" "crct10dif_generic" "chacha_generic" "af_alg"
      "encrypted_keys"
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
    device = "/dev/disk/by-uuid/d5530f58-e33b-40e7-8919-d0a7fe8df5e8";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/68DD-25F9";
    fsType = "vfat";
  };

  fileSystems."/var/lib/docker" = {
    device = "bohrium/local/docker";
    fsType = "zfs";
  };

  swapDevices = [
    { device = "/dev/mapper/bohrium-swap"; }
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0f0f", ATTR{idProduct}=="8006", MODE="0660", GROUP="users"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0f0f", ATTR{idProduct}=="0006", MODE="0660", GROUP="users"
  '';
}
