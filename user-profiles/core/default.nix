{ flake, pkgs, config, userName, lib, customUtils, ... }:
let
  userProfileSet = customUtils.types.attrNameSet (lib.zipAttrs (lib.attrValues flake.nixosModules.userProfiles));
in {
  options = {
    users.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options.profiles = lib.mkOption {
          type = userProfileSet;
          default = [];
          description = ''
            Set (list without duplicates) of ‘userProfiles’ enabled for this user
          '';
        };
      });
    };
  };

  config = {
    users.users.${userName} = {}; # Just make sure the user is created

    home-manager.users.${userName} = {
      # imports = lib.attrValues flake.homeManagerModules;
      config = {
        manual.manpages.enable = true;
        _module.args.pkgs = lib.mkForce pkgs;
        _module.args.nixos = config;
        _module.args.flake = flake;
      };
    };
  };
}
