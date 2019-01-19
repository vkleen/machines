{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ ];
  # boot.initrd.luks.devices = [ { device = "/dev/sda1"; name = "pv"; preLVM = true; allowDiscards = true; } ];
  # boot.initrd.luks.cryptoModules = [ "aegis256" "aegis256_aesni" "dm_integrity" "aes"
  #                                    "aes_generic" "aes_x86_64" "xts" "sha256" "sha512"
  #                                    "dm_bufio" "algif_aead" "algif_skcipher" "md4"
  #                                    "algif_hash" "arc4" "ctr" "cbc" "authenc" "cmac" "ccm"
  #                                  ];
  boot.initrd.supportedFilesystems = [ "ext4" ];
  boot.initrd.kernelModules = [ "virtio_scsi" "virtio_blk" "virtio_pci" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  hardware.enableRedistributableFirmware = true;

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  fileSystems."/" =
    { device = "/dev/sda3";
      fsType = "ext4";
      options = [ "discard" "relatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/sda1";
      fsType = "ext2";
    };

  swapDevices =
    [ { device = "/dev/sda2"; }
    ];
}
