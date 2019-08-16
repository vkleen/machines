{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./users.nix
      ./guests/guests.nix
    ];

  nix = {
    nixPath = [
      "nixpkgs=${pkgs.path}"
      "nixpkgs-overlays=${./overlays}"
    ];

    binaryCaches = [
      "https://cache.nixos.org/"
      "https://ntqrfoedxliczzavdvuwhzvhkxbhxbpv.cachix.org"
    ];

    binaryCachePublicKeys = [
      "seaborgium.1:0cDg6+fSZ4Z4L7T24SPPal5VN4m51P5o2NDfUycbKmo="
      "freyr.1:d8VFt+9VtvwWAMKEGEERpZtWWh8Z3bDf+O2HrOLjBYQ="
      "ntqrfoedxliczzavdvuwhzvhkxbhxbpv.cachix.org-1:reOmDDtgU13EasMsy993sq3AuzGmXwfSxNTYPfGf3Hc="
    ];
  };

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
    wget zsh i2c-tools
    tmux mosh batctl
    qemu
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
  };

  networking.firewall.enable = false;

  system.stateVersion = "19.03";

  hardware.opengl = {
    enable = true;
    extraPackages = []; #[ pkgs.rocm-opencl-icd ];
  };
  services.udisks2.enable = false;
  services.xserver.enable = false;

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = false;
    qemuRunAsRoot = false;
  };

  nix.buildCores = 144;
  nix.maxJobs = 144;
  nix.package = let
      all-overlays-in = dir: with builtins; with lib;
        let allNixFilesIn = dir: mapAttrs (name: _: import (dir + "/${name}"))
                                          (filterAttrs (name: _: hasSuffix ".nix" name)
                                          (readDir dir));
        in attrValues (allNixFilesIn dir);

      x86-pkgs = import "${pkgs.path}/pkgs/top-level" ({
        crossSystem = null;
        localSystem = {
          system = "x86_64-linux";
          platform = lib.systems.platforms.pc64;
        };
        overlays = all-overlays-in ./overlays;
      });
    in x86-pkgs.nixUnstable;#(pkgs.nix2_0_4.override { boehmgc = pkgs.boehmgc_766; }).overrideAttrs (_: { doInstallCheck = false; });
  nix.extraOptions = ''
    system = powerpc64le-linux
    filter-syscalls = false
    extra-platforms = x86_64-linux i686-linux powerpc64le-linux
    secret-key-files = /run/keys/chlorine.1.sec
  '';
  nix.useSandbox = false;

  boot.binfmtMiscRegistrations = {
    i386 = {
      fixBinary = true;
      interpreter = "${pkgs.qemu}/bin/qemu-i386";
      recognitionType = "magic";
      magicOrExtension = "\\x7fELF\\x01\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\x03\\x00";
      mask = "\\xff\\xff\\xff\\xff\\xff\\xfe\\xfe\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xfe\\xff\\xff\\xff";
    };
    i486 = {
      fixBinary = true;
      interpreter = "${pkgs.qemu}/bin/qemu-i386";
      recognitionType = "magic";
      magicOrExtension = "\\x7fELF\\x01\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\x06\\x00";
      mask = "\\xff\\xff\\xff\\xff\\xff\\xfe\\xfe\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xfe\\xff\\xff\\xff";
    };
    x86_64 = {
      fixBinary = true;
      interpreter = "${pkgs.qemu}/bin/qemu-x86_64";
      recognitionType = "magic";
      magicOrExtension = "\\x7fELF\\x02\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\x3e\\x00";
      mask = "\\xff\\xff\\xff\\xff\\xff\\xfe\\xfe\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xfe\\xff\\xff\\xff";
    };
  };

  guests = {
    "build-x86" = {
      type = "qemu";
      arch = "x86_64";
      memory = 50*1024;
      cores = 36;
      diskSize = 100;
      config = import ./guests/build-x86.nix;
    };
  };
}
