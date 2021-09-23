{ flake, flakeInputs, hostName, customUtils, config, lib, pkgs, ... }:
let
  inherit (lib) fileContents;
  profileSet = customUtils.types.attrNameSet flake.nixosModules.systemProfiles;
in
{
  imports = with flakeInputs;
    [ home-manager.nixosModules.home-manager
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
        utillinux
      ];
    };

    nixpkgs = {
      pkgs = flake.legacyPackages.${config.nixpkgs.system};
    };

    nix = {
      package = pkgs.nix;
      useSandbox = true;
      allowedUsers = [ "@wheel" ];
      trustedUsers = [ "root" "@wheel" ];
      extraOptions = ''
        experimental-features = nix-command flakes ca-references
      '';
      nixPath = [
        "nixpkgs=${flake.legacyPackages.${config.nixpkgs.system}.path}"
      ];
      registry =
        let override = { self = "nixos"; };
        in lib.mapAttrs' (inpName: inpFlake: lib.nameValuePair
          (override.${inpName} or inpName)
          { flake = inpFlake; } ) flakeInputs;
    };

    security = {
      protectKernelImage = false;
    };

    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true; # Otherwise home-manager would only work impurely

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
