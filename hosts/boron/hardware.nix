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
      "nhpoly1305_neon" "nhpoly1305" "chacha_generic" "chacha_neon" "libchacha" "adiantum" "libpoly1305"
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
    wait_target "device" /dev/disk/by-uuid/acbf65f7-1fd7-466c-84e5-93f3a9b2da01 30
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
