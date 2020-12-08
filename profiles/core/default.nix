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
    nix.package = pkgs.nixUnstable;
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
        ripgrep
        utillinux
        sudo
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
      hideProcessInformation = false;
      protectKernelImage = false;
    };

    users.mutableUsers = false;

    boot.cleanTmpDir = true;

    time.timeZone = "UTC";
    i18n.defaultLocale = "en_US.UTF-8";

    security.sudo.configFile = ''
      Defaults:root,%wheel env_keep+=TERMINFO_DIRS
      Defaults:root,%wheel env_keep+=TERMINFO
      Defaults env_keep+=SSH_AUTH_SOCK
      Defaults !lecture,insults,rootpw

      root        ALL=(ALL) SETENV: ALL
      %wheel      ALL=(ALL:ALL) SETENV: ALL
    '';

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
