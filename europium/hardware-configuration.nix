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
    device = "nodev";
    copyKernels = true;
    fsIdentifier = "label";
    extraConfig = "serial; terminal_input serial; terminal_output serial";
  };

  boot.kernelParams = [ "console=ttyS0" ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = [ "discard" "relatime" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];
}
