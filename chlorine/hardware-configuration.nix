{ config, lib, pkgs, ... }:

{
  imports =
    [
    ];

  boot.initrd.availableKernelModules = [ "nvme" "aacraid" "xhci_pci" "sd_mod" ];
  boot.kernelModules = [ "dm_snapshot" "dm_integrity" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks = {
    devices = {
      "chlorine_pv" = {
        device = "/dev/disk/by-uuid/6939b21d-b466-4b00-b79f-cee0ad92efd1";
      };
    };
    cryptoModules = [
      "aegis256" "aegis256_aesni" "dm_integrity" "aes"
      "aes_generic" "aes_x86_64" "xts" "sha256" "sha512"
      "dm_bufio" "algif_aead" "algif_skcipher" "md4"
      "algif_hash" "arc4" "ctr" "cbc" "authenc" "cmac" "ccm"
    ];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/978e4c7d-a137-469e-9fab-b202d02f11c1";
      fsType = "ext4";
    };

  swapDevices = [ ];
}
