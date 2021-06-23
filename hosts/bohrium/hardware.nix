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
      "aegis128-aesni" "aesni-intel" "blake2s-x86_64" "blowfish-x86_64"
      "camellia-aesni-avx-x86_64" "camellia-aesni-avx2" "camellia-x86_64"
      "cast5-avx-x86_64" "cast6-avx-x86_64" "chacha-x86_64" "crc32-pclmul"
      "crc32c-intel" "crct10dif-pclmul" "curve25519-x86_64" "des3_ede-x86_64"
      "ghash-clmulni-intel" "nhpoly1305-avx2" "nhpoly1305-sse2" "poly1305-x86_64"
      "serpent-avx-x86_64" "serpent-avx2" "serpent-sse2-x86_64" "sha1-ssse3"
      "sha256-ssse3" "sha512-ssse3" "twofish-avx-x86_64" "twofish-x86_64-3way"
      "twofish-x86_64" "842" "adiantum" "aegis128" "aes_generic" "aes_ti"
      "af_alg" "algif_aead" "algif_hash" "algif_rng" "algif_skcipher" "ansi_cprng"
      "anubis" "arc4" "asym_tpm" "pkcs7_test_key" "tpm_key_parser" "async_memcpy"
      "async_pq" "async_raid6_recov" "async_tx" "async_xor" "authenc" "authencesn"
      "blake2b_generic" "blake2s_generic" "blowfish_common" "blowfish_generic"
      "camellia_generic" "cast5_generic" "cast6_generic" "cast_common" "cbc"
      "ccm" "cfb" "chacha20poly1305" "chacha_generic" "cmac" "crc32_generic"
      "crc32c_generic" "crct10dif_common" "crct10dif_generic" "cryptd"
      "crypto_engine" "crypto_simd" "crypto_user" "ctr" "cts" "curve25519-generic"
      "deflate" "des_generic" "drbg" "ecb" "ecc" "ecdh_generic" "echainiv"
      "ecrdsa_generic" "essiv" "fcrypt" "gcm" "gf128mul" "ghash-generic"
      "jitterentropy_rng" "keywrap" "khazad" "lrw" "lz4" "lz4hc" "md4" "michael_mic"
      "nhpoly1305" "ofb" "pcbc" "pcrypt" "poly1305_generic" "rmd160" "seed" "seqiv"
      "serpent_generic" "sha3_generic" "sha512_generic" "sm2_generic" "sm3_generic"
      "sm4_generic" "streebog_generic" "tea" "twofish_common" "twofish_generic"
      "vmac" "wp512" "xcbc" "xor" "xts" "xxhash_generic" "zstd"
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
