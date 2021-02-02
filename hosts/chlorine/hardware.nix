{pkgs, lib, config, ...}:
{
  boot.wipeRoot = false;

  system.boot.loader.kernelFile = "vmlinux";
  system.build.installBootloader = lib.mkForce false;
  boot.loader.grub.enable = false;

  boot.kernelParams = [ "console=hvc0" ];
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ rocm-opencl-icd ];
  };

  boot.kernelModules = [ "dm_snapshot" "dm_integrity" "powernv-cpufreq" ];
  powerManagement.cpuFreqGovernor = "schedutil";

  boot.initrd.availableKernelModules = lib.mkForce (
     [ "nvme" "aacraid" "xhci_pci" "sd_mod" ]
  ++ config.boot.initrd.luks.cryptoModules
  );
  boot.extraModulePackages = [ ];

  boot.initrd.luks = {
    devices = {
      "chlorine_pv" = {
        device = "/dev/disk/by-uuid/6939b21d-b466-4b00-b79f-cee0ad92efd1";
      };
    };
    cryptoModules = [
      "sm2_generic" "essiv" "ofb" "sha1_generic" "khazad" "hmac" "ansi_cprng"
      "echainiv" "crypto_engine" "sm3_generic" "ghash-generic" "xxhash_generic"
      "seed" "aegis128" "drbg" "michael_mic" "blowfish_generic" "blake2b_generic"
      "salsa20_generic" "lrw" "algif_hash" "lz4hc" "blake2s_generic" "anubis"
      "tgr192" "ecc" "blowfish_common" "rmd320" "crct10dif_common" "crypto_user"
      "poly1305_generic" "rmd160" "adiantum" "crc32c_generic" "gf128mul" "md4"
      "async_tx" "pcbc" "gcm" "twofish_generic" "arc4" "rsa_generic" "tea"
      "twofish_common" "sha512_generic" "ecdh_generic" "crct10dif_generic"
      "cast5_generic" "xts" "sha256_generic" "authenc" "chacha_generic"
      "seqiv" "async_memcpy" "af_alg" "cast6_generic" "serpent_generic"
      "algif_skcipher" "nhpoly1305" "xor" "ecb" "ecrdsa_generic" "rmd256"
      "fcrypt" "wp512" "crc32_generic" "cts" "chacha20poly1305" "xcbc" "cmac"
      "md5" "async_raid6_recov" "async_xor" "sha3_generic" "aes_generic" "keywrap"
      "authencesn" "streebog_generic" "842" "cfb" "camellia_generic" "algif_aead"
      "sm4_generic" "async_pq" "lz4" "cbc" "des_generic" "deflate" "rmd128"
      "curve25519-generic" "aes_ti" "cast_common" "ccm" "jitterentropy_rng"
      "algif_rng" "cryptd" "zstd" "vmac" "pcrypt" "ctr"
    ];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/978e4c7d-a137-469e-9fab-b202d02f11c1";
      fsType = "ext4";
    };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    algorithm = "zstd";
  };
  swapDevices = [ ];

  hardware.firmware = [
    pkgs.firmwareLinuxNonfree
  ];
}
