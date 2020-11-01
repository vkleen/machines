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
      "serpent_generic" "algif_rng" "authencesn" "crct10dif_generic" "blowfish_generic" "aegis128" "crc32c_generic" "md4" "lz4hc" "cbc" "adiantum" "authenc" "seqiv" "ecdh_generic" "842" "pcbc" "curve25519-generic" "sha256_generic" "cmac" "async_tx" "async_raid6_recov" "async_memcpy" "async_xor" "gcm" "ccm" "async_pq" "sha512_generic" "echainiv" "anubis" "blowfish_common" "algif_hash" "tgr192" "ghash-generic" "crypto_simd" "michael_mic" "ansi_cprng" "cast_common" "rmd128" "sm4_generic" "twofish_common" "wp512" "zstd" "cast5_generic" "algif_skcipher" "crc32_generic" "sm3_generic" "nhpoly1305" "cryptd" "twofish_generic" "crypto_user" "af_alg" "des_generic" "rmd320" "salsa20_generic" "xts" "xxhash_generic" "ecrdsa_generic" "deflate" "rmd256" "camellia_generic" "lrw" "xor" "gf128mul" "ecc" "arc4" "crypto_engine" "ecb" "lz4" "xcbc" "aes_ti" "khazad" "streebog_generic" "cast6_generic" "blake2b_generic" "keywrap" "chacha_generic" "tea" "aes_generic" "fcrypt" "cts" "chacha20poly1305" "essiv" "hmac" "vmac" "poly1305_generic" "sha3_generic" "rmd160" "algif_aead" "ctr" "crct10dif_common" "jitterentropy_rng" "pcrypt" "serpent-avx-x86_64" "cast5-avx-x86_64" "twofish-x86_64-3way" "sha1-ssse3" "seed" "cfb" "blake2s_generic" "ofb" "cast6-avx-x86_64" "twofish-x86_64" "drbg" "serpent-sse2-x86_64" "camellia-aesni-avx2" "crct10dif-pclmul" "sha256-ssse3" "sha512-ssse3" "crc32-pclmul" "camellia-x86_64" "curve25519-x86_64" "nhpoly1305-avx2" "ghash-clmulni-intel" "poly1305-x86_64" "aegis128-aesni" "camellia-aesni-avx-x86_64" "blowfish-x86_64" "nhpoly1305-sse2" "crc32c-intel" "aesni-intel" "blake2s-x86_64" "twofish-avx-x86_64" "glue_helper" "chacha-x86_64" "serpent-avx2" "des3_ede-x86_64" "asym_tpm" "pkcs7_test_key" "tpm_key_parser"
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

  swapDevices = [
    { device = "/dev/mapper/bohrium-swap"; }
  ];
}
