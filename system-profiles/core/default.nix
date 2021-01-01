{ flake, flakeInputs, input-pkgs, hostName, customUtils, config, lib, pkgs, ... }:
let
  inherit (lib) fileContents;
  profileSet = customUtils.types.attrNameSet flake.nixosModules.systemProfiles;
in
{
  imports = with flakeInputs;
    [ sops-nix.nixosModules.sops
      home-manager.nixosModules.home-manager

      flake.nixosModules.wipe-root
    ];
  options = {
    # See mkSystemProfile in ../flake.nix
    system.profiles = lib.mkOption {
      type = profileSet;
      default = [];
      description = ''
        Set (list without duplicates) of ‘systemProfiles’ enabled for this host
      '';
    };
  };
  config = {
    networking.hostName = hostName;
    system.configurationRevision = lib.mkIf (flake ? rev) flake.rev;

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
        sudo
        utillinux
      ];
    };

    nixpkgs = {
      pkgs = flake.legacyPackages.${config.nixpkgs.system};
    };

    nix = {
      package = pkgs.nixUnstable;
      useSandbox = true;
      allowedUsers = [ "@wheel" ];
      trustedUsers = [ "root" "@wheel" ];
      extraOptions = ''
        experimental-features = nix-command flakes ca-references
      '';
      nixPath = [
        "nixpkgs=${config.nixpkgs.pkgs.path}"
        "nixpkgs-overlays=${flake.overlays-path."${config.nixpkgs.system}"}"
      ];
      registry = {
        nixpkgs.flake = input-pkgs;
        home-manager.flake = flakeInputs.home-manager;
        machines.flake = flake;
      };
    };

    security = {
      hideProcessInformation = false;
      protectKernelImage = false;
    };

    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true; # Otherwise home-manager would only work impurely

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
