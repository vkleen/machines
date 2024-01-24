{ ... }:
{
  # cryptsetup:
  #   cryptsetup luksFormat /dev/nvme0n1p2 --cipher='aes-xts-plain64' --key-size=512 --hash=sha256 --type luks1
  #   cryptsetup luksFormat /dev/nvme0n1p3 --cipher='capi:adiantum(xchacha20,aes)-plain64' --key-size=256 --keyslot-key-size=512 --keyslot-cipher=aes-xts-plain64 --pbkdf=argon2i --hash=blake2b512 --sector-size=4096
  #   cryptsetup luksFormat /dev/nvme0n1p4 --cipher='capi:adiantum(xchacha20,aes)-plain64' --key-size=256 --keyslot-key-size=512 --keyslot-cipher=aes-xts-plain64 --pbkdf=argon2i --hash=blake2b512 --sector-size=4096
  #   cryptsetup luksAddKey /dev/nvme0n1p2 /persist/private/keyfiles/boot
  #   cryptsetup luksAddKey /dev/nvme0n1p3 /persist/private/keyfiles/swap
  #   cryptsetup luksAddKey /dev/nvme0n1p4 /persist/private/keyfiles/data
  #
  # ZFS formatting: DON'T use utf8only again
  #   zpool create -o ashift=12 -O encryption=aes-256-ccm -O keyformat=passphrase -O keylocation=file:///persist/private/zfs -O mountpoint=none bohrium /dev/mapper/bohrium-data
  #   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off bohrium/local/root
  #   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off -o compression=lz4 bohrium/local/nix
  #   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off -o compression=lz4 bohrium/safe/home
  #   zfs create -p -o mountpoint=legacy -o utf8only=on -o acltype=posixacl -o xattr=sa -o atime=off -o compression=lz4 bohrium/safe/persist
  #   zfs create -p -o mountpoint=legacy -o acltype=posixacl -o xattr=sa -o atime=off -o compression=lz4 bohrium/safe/yt
  #   zfs create -o refreservation=1G -o mountpoint=none bohrium/local/reserved

  #   zfs set com.sun:auto-snapshot=true bohrium/safe
  #   zfs set com.sun:auto-snapshot=false bohrium/safe/yt
  boot.initrd.luks = {
    devices = {
      "bohrium-swap" = {
        device = "/dev/disk/by-uuid/7d817c0f-c3d4-46dc-9d30-eed825675684";
        keyFile = "/persist/private/keyfiles/swap";
      };
      "bohrium-data" = {
        device = "/dev/disk/by-uuid/8f4e99fb-ffe0-44eb-8e18-13ae20b5368e";
        keyFile = "/persist/private/keyfiles/data";
      };
      "bohrium-boot" = {
        device = "/dev/disk/by-uuid/1f2e2852-e026-406a-83cf-310bf1ceae4f";
        keyFile = "/persist/private/keyfiles/boot";
      };
    };
  };

  boot.initrd.secrets = {
    "/persist/private/keyfiles/swap" = null;
    "/persist/private/keyfiles/data" = null;
    "/persist/private/keyfiles/boot" = null;
    "/persist/private/zfs" = null;
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
    device = "/dev/disk/by-uuid/9043fcad-e770-462c-8bfc-788717d4dc76";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/DF2D-4BCA";
    fsType = "vfat";
  };

  fileSystems."/var/lib/docker" = {
    device = "bohrium/local/docker";
    fsType = "zfs";
  };

  fileSystems."/var/lib/libvirt" = {
    device = "bohrium/local/libvirt";
    fsType = "zfs";
  };

  # fileSystems."/home/vkleen/yt" = {
  #   device = "bohrium/safe/yt";
  #   fsType = "Zfs";
  # };

  swapDevices = [
    { device = "/dev/mapper/bohrium-swap"; }
  ];
}
