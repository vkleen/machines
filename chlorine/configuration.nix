{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./users.nix
      # ./guests/guests.nix
    ];

  nix = {
    nixPath = [
      "nixpkgs=${pkgs.path}"
      "nixpkgs-overlays=${./overlays}"
    ];

    binaryCaches = [
      "s3://vkleen-nix-cache?region=eu-central-1"
    ];

    binaryCachePublicKeys = [
      "seaborgium.1:0cDg6+fSZ4Z4L7T24SPPal5VN4m51P5o2NDfUycbKmo="
      (import ../cache-keys/aws-vkleen-nix-cache-1.public)
    ];
  };

  system.build.squashfsStore = pkgs.buildPackages.callPackage "${pkgs.path}/nixos/lib/make-squashfs.nix" {
    storeContents = [
      config.system.build.toplevel
    ];
  };

  system.build.tarball = pkgs.buildPackages.callPackage "${pkgs.path}/nixos/lib/make-system-tarball.nix" {
    storeContents = [
      { object = config.system.build.toplevel;
        symlink = "/run/current-system";
      }
    ];
    contents = [
      { source = config.system.build.initialRamdisk + "/" + config.system.boot.loader.initrdFile;
        target = "/boot/" + config.system.boot.loader.initrdFile;
      }
      { source = config.system.build.kernel + "/" + config.system.boot.loader.kernelFile;
        target = "/boot/" + config.system.boot.loader.kernelFile;
      }
    ];
  };

  boot.postBootCommands =
  ''
    # After booting, register the contents of the Nix store on the
    # CD in the Nix database in the tmpfs.
    if [ -f /nix-path-registration ]; then
      ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration &&
      rm /nix-path-registration
    fi

    # nixos-rebuild also requires a "system" profile and an
    # /etc/NIXOS tag.
    touch /etc/NIXOS
    ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
  '';

  system.build.netbootRamdisk = pkgs.makeInitrd {
    inherit (config.boot.initrd) compressor;
    prepend = [ "${config.system.build.initialRamdisk}/initrd" ];

    contents =
      [ { object = config.system.build.squashfsStore;
          symlink = "/nix-store.squashfs";
        }
      ];
  };
  system.build.netboot-params = pkgs.buildPackages.writeText "netboot-params" ''
    kernel ${toString config.system.build.kernel}/${toString config.system.boot.loader.kernelFile} init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}
    initrd ${toString config.system.build.netbootRamdisk}/${toString config.system.boot.loader.initrdFile}
  '';

  system.boot.loader.kernelFile = "vmlinux";
  system.build.installBootloader = lib.mkForce false;
  boot.loader.grub.enable = false;

  boot.kernelParams = [ "console=hvc0" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "chlorine";
  networking.hostId = "53199d00";

  environment.etc.machine-id.text = "53199d006f21acb7707e9ed34c1c4a3a";

  boot.initrd.availableKernelModules = [ "nvme" "ast" "xfs" "squashfs" ];
  boot.initrd.kernelModules = [ "loop" ];
  boot.initrd.supportedFilesystems = [ "xfs" "ext4" "ext3" "btrfs" ];

  time.timeZone = "UTC";

  environment.systemPackages = with pkgs; [
    wget zsh i2c-tools
    pciutils numactl
    vim
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
    enable = false;
    extraPackages = [];
  };
  services.udisks2.enable = false;
  services.xserver.enable = false;
  security.polkit.enable = false;

  virtualisation.libvirtd = {
    enable = false;
    qemuOvmf = false;
    qemuRunAsRoot = false;
  };

  boot.kernelModules = [ "powernv-cpufreq" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  nix.buildCores = 144;
  nix.maxJobs = 144;

  nix.extraOptions = ''
    system = powerpc64le-linux
    secret-key-files = /run/keys/chlorine.1.sec
  '';

  boot.binfmt.emulatedSystems = [
    "x86_64-linux" "i686-linux" "armv6l-linux" "armv7l-linux"
  ];

  security.sudo.configFile = ''
    Defaults:root,%wheel env_keep+=TERMINFO_DIRS
    Defaults:root,%wheel env_keep+=TERMINFO
    Defaults env_keep+=SSH_AUTH_SOCK
    Defaults !lecture,insults,rootpw

    root        ALL=(ALL) SETENV: ALL
    %wheel      ALL=(ALL:ALL) SETENV: ALL
  '';
}
