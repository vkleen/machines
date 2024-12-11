{ inputs, pkgs, lib, ... }:
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  config = {
    boot.initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "kvm-amd" ];

      systemd.enable = true;
      systemd.emergencyAccess = false;
    };

    boot.loader = {
      supportsInitrdSecrets = lib.mkForce false;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = lib.mkForce false;
      };
    };

    environment.systemPackages = [ pkgs.sbctl ];
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    environment.persistence."/persist".directories = [
      "/etc/secureboot"
    ];
  };
}
