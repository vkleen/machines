{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./users.nix
    ];

  nix.nixPath = [
    "nixpkgs=${pkgs.path}"
    "nixpkgs-overlays=${./overlays}"
  ];

  system.boot.loader.kernelFile = "vmlinux";
  system.build.installBootloader = lib.mkForce false;
  boot.loader.grub.enable = false;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "chlorine";
  networking.hostId = "5c1f0c11";

  environment.etc.machine-id.text = "5c1f0c11dba9b38e50f807605baacc6f";

  boot.initrd.availableKernelModules = [ "nvme" "ast" "xfs" ];
  boot.initrd.supportedFilesystems = [ "xfs" "ext4" "ext3" "btrfs" ];

  time.timeZone = "UTC";

  environment.systemPackages = with pkgs; [
    wget vim zsh i2c-tools
    tmux
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
  };

  networking.firewall.enable = false;

  system.stateVersion = "19.03";

  hardware.opengl.enable = true;
  services.xserver.enable = false;

  nix.buildCores = 144;
  nix.maxJobs = 144;
  nix.package = (pkgs.nix2_0_4.override { boehmgc = pkgs.boehmgc_766; }).overrideAttrs (_: { doInstallCheck = false; });
}
