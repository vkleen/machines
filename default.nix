args@{ override-rev ? null, override-pkgs ? null }:
let
  pkgs-path = args.override-pkgs or (import ./fetch-nixpkgs.nix { inherit override-rev; });
  lib = import "${pkgs-path}/lib";

  nixpkgs-x86_64 = args: import "${pkgs-path}/pkgs/top-level" ({
    crossSystem = null;
    localSystem = {
      system = "x86_64-linux";
      platform = lib.systems.platforms.pc64;
    };
  } // args);

  all-overlays-in = dir: with builtins; with lib;
    let allNixFilesIn = dir: mapAttrs (name: _: import (dir + "/${name}"))
                                      (filterAttrs (name: _: hasSuffix ".nix" name)
                                      (readDir dir));
    in attrValues (allNixFilesIn dir);

  seaborgium-pkgs = nixpkgs-x86_64 {
    config = { allowUnfree = true;
               retroarch.enableHiganSFC = true;
               android_sdk.accept_license = true;
             };
    overlays = all-overlays-in ./seaborgium/overlays;
  };
  seaborgium = seaborgium-pkgs.nixos (import ./seaborgium/configuration.nix);

  bohrium-pkgs = nixpkgs-x86_64 {
    config = { allowUnfree = true;
               android_sdk.accept_license = true;
             };
    overlays = all-overlays-in ./bohrium/overlays;
  };
  bohrium = bohrium-pkgs.nixos (import ./bohrium/configuration.nix);

  samarium = (nixpkgs-x86_64 {
    overlays = all-overlays-in ./samarium/overlays;
  }).nixos (import ./samarium/configuration.nix);
  plutonium = (nixpkgs-x86_64 {
    overlays = all-overlays-in ./plutonium/overlays;
  }).nixos (import ./plutonium/configuration.nix);

  installer = (nixpkgs-x86_64 {}).nixos ({pkgs, lib, ...}: {
    imports = [
      "${pkgs-path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ];
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.supportedFilesystems = [ "zfs" ];
    boot.kernelParams = [ "console=tty0" "console=ttyS0" ];
    boot.zfs = {
      enableUnstable = true;
      forceImportRoot = false;
      forceImportAll = false;
    };
    networking.hostId = "9c4940eb";
    environment.etc.machine-id.text = "9c4940eb9b564dd759092e215bcbc157";

    users = {
      mutableUsers = false;
      extraUsers = {
        "root" = {
          hashedPassword = "$6$rounds=500000$LOTAq.HWQYxy$lKdVbv3O7kER44KRcmVL6q5Ahvwi78CfLNVElX/KwXuqXsAu6L9NQ98Y2BWbkI9fHyuqr8lBfD30BTgikLhB20";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
          ];
        };
      };
    };
  });

  nixpkgs-ppc64 = args: import "${pkgs-path}/pkgs/top-level" ({
    config = {
      allowUnsupportedSystem = true;
    };
    crossSystem = null;
    #localSystem = {
    #  system = "x86_64-linux";
    #  platform = lib.systems.platforms.pc64;
    #};
    localSystem = {
      system = "powerpc64le-linux";
      platform = lib.systems.platforms.powernv;
    };
  } // args);
  chlorine = (nixpkgs-ppc64 {
    overlays = all-overlays-in ./chlorine/overlays;
  }).nixos (import ./chlorine/configuration.nix);

  nixpkgs-arm = args: import "${pkgs-path}" ({
    config = {};
    overlays = all-overlays-in ./chlorine/overlays;
    localSystem = {
      system = "powerpc64le-linux";
      platform = lib.systems.platforms.powernv;
    };
    crossSystem = (import "${pkgs-path}/lib").systems.examples.armv7l-hf-multiplatform;
    crossOverlays = [
      (self: super: {
        gobject-introspection = (super.gobject-introspection.override { x11Support = false; }).overrideAttrs (o: {
          nativeBuildInputs = o.nativeBuildInputs ++ [ self.python3 self.flex self.bison ];
        });
      })
    ];
    # crossSystem = {
    #   config = "armv7l-unknown-linux-gnueabi";
    #   platform = {
    #     name = "novena";
    #     kernelMajor = "2.6"; # Using "2.6" enables 2.6 kernel syscalls in glibc.
    #     kernelBaseConfig = "multi_v7_defconfig";
    #     kernelArch = "arm";
    #     kernelDTB = true;
    #     kernelAutoModules = true;
    #     kernelPreferBuiltin = true;
    #     kernelTarget = "zImage";
    #     kernelExtraConfig = ''
    #       # Serial port for Raspberry Pi 3. Upstream forgot to add it to the ARMv7 defconfig.
    #       SERIAL_8250_BCM2835AUX y
    #       SERIAL_8250_EXTENDED y
    #       SERIAL_8250_SHARE_IRQ y

    #       # Fix broken sunxi-sid nvmem driver.
    #       TI_CPTS y

    #       # Hangs ODROID-XU4
    #       ARM_BIG_LITTLE_CPUIDLE n

    #       # Disable OABI to have seccomp_filter (required for systemd)
    #       # https://github.com/raspberrypi/firmware/issues/651
    #       OABI_COMPAT n
    #     '';
    #     gcc = {
    #       arch = "armv7-a";
    #       fpu = "neon-fp16";
    #     };
    #   };
    # };
  } // args);

  novena-pkgs = nixpkgs-arm {};
  novena-install = novena-pkgs.nixos ({pkgs, lib, config, ...}: {
    imports = [
      # "${pkgs-path}/nixos/modules/profiles/minimal.nix"
      # "${pkgs-path}/nixos/modules/installer/cd-dvd/sd-image.nix"
    ];
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;

    environment.noXlibs = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

    services.udisks2.enable = false;
    services.xserver.enable = false;
    fonts.fontconfig.enable = false;
    documentation.enable = false;
    security.polkit.enable = false;
    xdg.mime.enable = false;

    system.build.installBootloader = lib.mkForce false;
    nix = {
      nixPath = [
        "nixpkgs=${pkgs.path}"
      ];
    };


    fileSystems = {
      "/boot/firmware" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        # Alternatively, this could be removed from the configuration.
        # The filesystem is not needed at runtime, it could be treated
        # as an opaque blob instead of a discrete FAT32 filesystem.
        options = [ "nofail" "noauto" ];
      };
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };
    };


    environment.systemPackages = [
      pkgs.parted
      pkgs.gptfdisk
      # pkgs.ddrescue
      pkgs.cryptsetup # needed for dm-crypt volumes
      pkgs.mkpasswd # for generating password files

      # Some text editors.
      pkgs.vim

      # Some networking tools.
      pkgs.socat
      # pkgs.screen

      # Hardware-related tools.
      pkgs.sdparm
      pkgs.hdparm
      pkgs.smartmontools # for diagnosing hard disks
      pkgs.pciutils
      pkgs.usbutils

      # Tools to create / manipulate filesystems.
      pkgs.dosfstools
      pkgs.e2fsprogs

      # Some compression/archiver tools.
      pkgs.p7zip

      # pkgs.ubootTools
      pkgs.ubootNovena
    ];
    boot.supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];

    boot.consoleLogLevel = lib.mkDefault 7;
    boot.kernelParams = ["console=ttyS0,115200n8" "console=ttymxc0,115200n8" "console=ttyAMA0,115200n8" "console=ttyO0,115200n8" "console=ttySAC2,115200n8" "console=tty0"];

    users = {
      mutableUsers = false;
      extraUsers = {
        "root" = {
          hashedPassword = "$6$rounds=500000$LOTAq.HWQYxy$lKdVbv3O7kER44KRcmVL6q5Ahvwi78CfLNVElX/KwXuqXsAu6L9NQ98Y2BWbkI9fHyuqr8lBfD30BTgikLhB20";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
          ];
        };
      };
    };
  });


  amazon-image = (nixpkgs-x86_64 {}).nixos ({pkgs, lib, config, ...}: {
    imports = [
      ./amazon.nix
    ];
    config.boot.kernelParams = [ "nvme_core.io_timeout=255" ];
    config.system.build.amazonImage = let
      in import "${pkgs.path}/nixos/lib/make-disk-image.nix" rec {
        inherit pkgs lib config;
        contents = [];
        format = "vpc";
        name = "nixos-amazon-image-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
        partitionTableType = if config.ec2.efi then "efi"
                             else if config.ec2.hvm then "legacy"
                             else "none";
        diskSize = 2048;
        fsType = "ext4";
        configFile = pkgs.writeText "configuration.nix"
          ''
            {
              imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
              ${lib.optionalString config.ec2.hvm ''
                ec2.hvm = true;
              ''}
              ${lib.optionalString config.ec2.efi ''
                ec2.efi = true;
              ''}
            }
          '';
        postVM = ''
          extension=''${diskImage##*.}
          friendlyName=$out/${name}.$extension
          mv "$diskImage" "$friendlyName"
          diskImage=$friendlyName

          mkdir -p $out/nix-support
          echo "file ${format} $diskImage" >> $out/nix-support/hydra-build-products

          ${pkgs.jq}/bin/jq -n \
            --arg label ${lib.escapeShellArg config.system.nixos.label} \
            --arg system ${lib.escapeShellArg pkgs.stdenv.hostPlatform.system} \
            --arg logical_bytes "$(${pkgs.qemu}/bin/qemu-img info --output json "$diskImage" | ${pkgs.jq}/bin/jq '."virtual-size"')" \
            --arg file "$diskImage" \
            '$ARGS.named' \
            > $out/nix-support/image-info.json
        '';
      };
  });
in {
  inherit seaborgium seaborgium-pkgs;
  inherit bohrium bohrium-pkgs;

  inherit samarium plutonium;

  installer-iso = installer.isoImage;

  chlorine-bootstrap = (import "${pkgs-path}/pkgs/stdenv/linux/make-bootstrap-tools-cross.nix" { system = "powerpc64le-linux"; }).powerpc64le;
  chlorine-musl-bootstrap = (import "${pkgs-path}/pkgs/stdenv/linux/make-bootstrap-tools-cross.nix" { system = "powerpc64le-linux"; }).powerpc64le-musl;
  chlorine-pkgs = nixpkgs-ppc64 {
    overlays = all-overlays-in ./chlorine/overlays;
  };
  inherit chlorine;

  chlorine-guest-base = chlorine.guests.base-x86_64;

  amazon-image = amazon-image.toplevel;
  aws-ami = amazon-image.amazonImage;

  inherit novena-pkgs novena-install;
  novena-uboot = novena-pkgs.ubootNovena;

  inherit (import "${pkgs-path}/lib") version;
}
