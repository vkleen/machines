{ flake, flakeInputs, path, hostName, config, lib, pkgs, customUtils, ... }:
let
  profileSet = customUtils.types.attrNameSet flake.nixosModules.systemProfiles;
in {
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

    nixpkgs.pkgs = flakeInputs.nixpkgs.legacyPackages.${config.nixpkgs.system};
    nixpkgs.overlays = lib.attrValues flake.overlays;

    nix = {
      package = pkgs.nixUnstable;
      useSandbox = true;
      allowedUsers = [ "@wheel" ];
      trustedUsers = [ "root" "@wheel" ];
      extraOptions = ''
        experimental-features = nix-command flakes ca-references
      '';
      nixPath = [
        "nixpkgs=${path}"
      ];
      registry = {
        nixpkgs.flake = flakeInputs.nixpkgs;
        home-manager.flake = flakeInputs.home-manager;
        machines.flake = flake;
      };
    };

    users.mutableUsers = false;

    # documentation.nixos.includeAllModules = true; # incompatible with home-manager (build fails)

    home-manager.useGlobalPkgs = true; # Otherwise home-manager would only work impurely
  };
}
