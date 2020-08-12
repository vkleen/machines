args@{ override-rev ? null, override-pkgs ? null }:
let
  pkgs-path = args.override-pkgs or (import ./fetch-nixpkgs.nix { inherit override-rev; });
  pkgs-power9-path = args.override-pkgs or (import ./fetch-nixpkgs.nix { inherit override-rev; override-json = ./nixpkgs-power9-src.json; });
  lib = import "${pkgs-path}/lib";

  nixpkgs-x86_64 = args: import "${pkgs-path}/pkgs/top-level" ({
    crossSystem = null;
    localSystem = {
      system = "x86_64-linux";
      platform = lib.systems.platforms.pc64;
    };
  } // args);

  nixpkgs-cross-x86_64 = args: import "${pkgs-power9-path}/pkgs/top-level" ({
    crossSystem = {
      system = "x86_64-linux";
      platform = lib.systems.platforms.pc64;
    };
    localSystem = {
      system = "powerpc64le-linux";
      platform = lib.systems.platforms.powernv;
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

  bohrium-cross-pkgs = nixpkgs-cross-x86_64 {
    config = { allowUnfree = true;
               android_sdk.accept_license = true;
             };
    overlays =    (all-overlays-in ./chlorine/overlays)
               ++ (all-overlays-in ./bohrium/overlays);
  };
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
  europium = (nixpkgs-x86_64 {
    overlays = all-overlays-in ./europium/overlays;
  }).nixos (import ./europium/configuration.nix);
  plutonium = (nixpkgs-x86_64 {
    overlays = all-overlays-in ./plutonium/overlays;
  }).nixos (import ./plutonium/configuration.nix);

  installer = (nixpkgs-x86_64 {}).nixos ({pkgs, lib, ...}: {
    imports = [
      "${pkgs-path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ./seaborgium/secrets.nix
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

    networking = {
      wireless.enable = false;
      wireless.iwd.enable = false;
    };
    systemd.services.supplicant-wlan0.partOf = lib.mkForce [];

    users = {
      mutableUsers = false;
      extraUsers = {
        "root" = {
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
          ];
        };
      };
    };
  });

  nixpkgs-ppc64 = args: import "${pkgs-power9-path}/pkgs/top-level" ({
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
  chlorine-pkgs = nixpkgs-ppc64 {
    overlays = all-overlays-in ./chlorine/overlays;
  };
  chlorine = chlorine-pkgs.nixos (import ./chlorine/configuration.nix);

  nixpkgs-arm = args: import "${pkgs-path}/pkgs/top-level" ({
    config = {};
    # overlays = all-overlays-in ./chlorine/overlays;
    localSystem = {
      system = "x86_64-linux";
      platform = lib.systems.platforms.pc64;
    };
    crossSystem = (import "${pkgs-path}/lib").systems.examples.armv7l-hf-multiplatform;
  } // args);

  novena-pkgs = nixpkgs-arm {
    crossOverlays = [
      (self: super: {
        gobject-introspection = (super.gobject-introspection.override { x11Support = false; }).overrideAttrs (o: {
          nativeBuildInputs = o.nativeBuildInputs ++ [ self.python3 self.flex self.bison ];
        });
        libftdi1 = super.libftdi1.override { docSupport = false; };
        flashrom = super.flashrom.overrideAttrs (o: {
          mesonFlags = [ "-Dconfig_ft2232_spi=false" "-Dconfig_nic3com=false" "-Dconfig_rayer_spi=false" "-Dconfig_satamv=false" "-Dconfig_nicrealtek=false" "-Dconfig_usbblaster_spi=false" ];
          postPatch = ''
            sed -i 's;^need_raw_access = false$;need_raw_access = true;' meson.build
          '';
          buildInputs = with super; [ libusb1 pciutils ];
        });
      })
    ];
  };
  novena-install = novena-pkgs.nixos ({pkgs, lib, config, ...}: {
    imports = [
      # "${pkgs-path}/nixos/modules/profiles/minimal.nix"
      "${pkgs-path}/nixos/modules/installer/cd-dvd/sd-image.nix"
    ];
    sdImage = {
      populateFirmwareCommands = "";
      populateRootCommands = "";
    };

    networking.hostName = "novena";

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

      # pkgs.ubootTools
      pkgs.ubootNovena

      pkgs.flashrom
    ];
    boot.supportedFilesystems = lib.mkForce [ "vfat" "ext4" "zfs" ];
    boot.zfs = {
      enableUnstable = true;
      forceImportRoot = false;
      forceImportAll = false;
    };
    services.zfs.zed.settings = {
      ZED_EMAIL_PROG = "${pkgs.coreutils}/bin/true";
    };
    networking.hostId = "cc6b36a1";
    environment.etc."machine-id".text = "cc6b36a180ac98069c5e6266bf0b4041";

    boot.kernelParams = ["console=ttymxc1,115200n8" "console=ttymxc0,115200n8"];

    services.openssh.enable = true;

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

  nixpkgs-boron = nixpkgs-arm {
    crossOverlays = all-overlays-in ./boron/overlays;
    crossSystem = let
      orig = (import "${pkgs-path}/lib").systems.examples.armv7l-hf-multiplatform;
    in orig // {
      platform = orig.platform // {
        kernelTarget = "uImage";
        kernelMakeFlags = [ "LOADADDR=0x12000000" "EXTRA_CFLAGS=-DVERBOSE=1" ];
      };
    };
  };
  boron = nixpkgs-boron.nixos (import ./boron/configuration.nix);

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
  inherit bohrium-cross-pkgs;

  inherit samarium europium plutonium;

  inherit boron;
  boron-pkgs = nixpkgs-boron;

  inherit installer;

  chlorine-bootstrap = (import "${pkgs-path}/pkgs/stdenv/linux/make-bootstrap-tools-cross.nix" { system = "powerpc64le-linux"; }).powerpc64le;
  chlorine-musl-bootstrap = (import "${pkgs-path}/pkgs/stdenv/linux/make-bootstrap-tools-cross.nix" { system = "powerpc64le-linux"; }).powerpc64le-musl;
  inherit chlorine chlorine-pkgs;

  chlorine-guest-base = chlorine.guests.base-x86_64;

  amazon-image = amazon-image.toplevel;
  aws-ami = amazon-image.amazonImage;

  inherit novena-pkgs novena-install;
  novena-uboot = novena-pkgs.ubootNovena.overrideAttrs (o: {
    buildInputs = (o.buildInputs or []) ++ [ novena-pkgs.pkg-config ];
    nativeBuildInputs = o.nativeBuildInputs ++ [ novena-pkgs.buildPackages.ncurses novena-pkgs.buildPackages.ncurses.dev novena-pkgs.buildPackages.pkg-config novena-pkgs.buildPackages.lzop novena-pkgs.buildPackages.libusb1 ];
  });

  inherit (import "${pkgs-path}/lib") version;


}
