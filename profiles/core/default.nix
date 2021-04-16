{ flake, config, lib, pkgs, ... }:
let inherit (lib) fileContents;
in
{
  imports = [
    flake.nixosModules.wipe-root
  ];
  options = {
    system.configuration-type = lib.mkOption {
      type = lib.types.str;
      default = "core";
    };
    system.extra-profiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };
  config = {
    nix.package = pkgs.nixUnstable.overrideAttrs (_: {
      doInstallCheck = false;
    });
    environment = {
      noXlibs = true;
      systemPackages = with pkgs; [
        binutils
        coreutils
        curl
        dnsutils
        fd
        git
        gptfdisk
        iputils
        jq
        lzop
        mbuffer
        ripgrep
        utillinux
      ];
    };

    nix = {
      useSandbox = true;
      allowedUsers = [ "@wheel" ];
      trustedUsers = [ "root" "@wheel" ];
      extraOptions = ''
        experimental-features = nix-command flakes ca-references
      '';
    };

    security = {
      protectKernelImage = false;
    };

    users.mutableUsers = false;

    boot.cleanTmpDir = true;

    time.timeZone = "UTC";
    i18n.defaultLocale = "en_US.UTF-8";

    security.doas = {
      enable = true;
      extraRules = lib.mkForce [
        { groups = [ "wheel" ]; keepEnv = true; noPass = false; persist = true; }
      ];
    };

    security.sudo.enable = false;

    services.ntp.enable = false;
    services.chrony = {
      enable = true;
      initstepslew = {
        enabled = true;
        threshold = 1000;
      };
    };
  };
}
