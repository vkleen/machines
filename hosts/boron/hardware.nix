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
#   zpool create -o ashift=12 -O mountpoint=none boron /dev/mapper/boron-data
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off boron/local/root
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off boron/local/nix
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off boron/safe/home
#   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off boron/safe/persist
#   zfs create -o refreservation=1G -o mountpoint=none boron/local/reserved

#   zfs set com.sun:auto-snapshot=true boron/safe
  boot.initrd.kernelModules = [ "xhci_hcd" "usb_storage" "sd_mod" "uas" ];

  boot.initrd.luks = {
    devices = {
      "boron-swap" = {
        device = "/dev/disk/by-uuid/26bbe54d-7c19-4cd9-9448-609d77d1814e";
        keyFile = "/persist/private/keyfiles/swap";
      };
      "boron-data" = {
        device = "/dev/disk/by-uuid/ad7123e8-445b-4354-8294-6fbd45bec37d";
        keyFile = "/persist/private/keyfiles/data";
      };
    };
    cryptoModules = [
      "aes-neon-blk" "aes-neon-bs" "chacha-neon" "crct10dif-ce" "nhpoly1305-neon" "poly1305-neon" "sha3-ce" "sha512-arm64" "sha512-ce" "sm3-ce" "sm4-ce" "842" "adiantum" "aegis128" "aes_ti" "af_alg" "algif_aead" "algif_hash" "algif_rng" "algif_skcipher" "anubis" "arc4" "asym_tpm" "pkcs7_test_key" "tpm_key_parser" "async_memcpy" "async_pq" "async_raid6_recov" "async_tx" "async_xor" "authenc" "authencesn" "blake2b_generic" "blake2s_generic" "blowfish_common" "blowfish_generic" "camellia_generic" "cast5_generic" "cast6_generic" "cast_common" "cbc" "ccm" "cfb" "chacha20poly1305" "chacha_generic" "cmac" "crc32_generic" "crypto_engine" "crypto_user" "ctr" "cts" "curve25519-generic" "des_generic" "ecb" "ecc" "ecdh_generic" "ecdsa_generic" "ecrdsa_generic" "essiv" "fcrypt" "gcm" "ghash-generic" "keywrap" "khazad" "lrw" "lz4" "lz4hc" "md4" "md5" "michael_mic" "nhpoly1305" "ofb" "pcbc" "pcrypt" "poly1305_generic" "rmd160" "seed" "seqiv" "serpent_generic" "sha3_generic" "sha512_generic" "sm2_generic" "sm3_generic" "sm4_generic" "streebog_generic" "tea" "twofish_common" "twofish_generic" "vmac" "wp512" "xcbc" "xor" "xts" "xxhash_generic" "zstd"
    ];
  };

  boot.initrd.preLVMCommands = lib.mkBefore ''
    dev_exist() {
        local target="$1"
        if [ -e $target ]; then
            return 0
        else
            local uuid=$(echo -n $target | sed -e 's,UUID=\(.*\),\1,g')
            blkid --uuid $uuid >/dev/null
            return $?
        fi
    }

    wait_target() {
        local name="$1"
        local target="$2"
        local secs="''${3:-10}"
        local desc="''${4:-$name $target to appear}"

        if ! dev_exist $target; then
            echo -n "Waiting $secs seconds for $desc..."
            local success=false;
            for try in $(seq $secs); do
                echo -n "."
                sleep 1
                if dev_exist $target; then
                    success=true
                    break
                fi
            done
            if [ $success == true ]; then
                echo " - success";
                return 0
            else
                echo " - failure";
                return 1
            fi
        fi
        return 0
    }
    wait_target "device" /dev/disk/by-uuid/ad7123e8-445b-4354-8294-6fbd45bec37d 30
  '';

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
    device = "boron/local/root";
    fsType = "zfs";
  };
  fileSystems."/nix" = {
    device = "boron/local/nix";
    fsType = "zfs";
  };
  fileSystems."/persist" = {
    device = "boron/safe/persist";
    fsType = "zfs";
  };
  fileSystems."/home" = {
    device = "boron/safe/home";
    fsType = "zfs";
  };

  swapDevices = [
    { device = "/dev/mapper/boron-swap"; }
  ];
}

