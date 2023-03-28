{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nix-monitored = {
      url = "github:ners/nix-monitored";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      lib = import ./lib { inherit inputs; };
      buildPlatforms = [ "x86_64-linux" "aarch64-linux" "riscv64-linux" "powerpc64le-linux" ];
    in {
      inherit lib;
      nixosModules = lib.findModules ./modules;
    } // lib.foreach buildPlatforms (buildPlatform:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${buildPlatform};
        hostSystem = lib.systems.parse.mkSystemFromString buildPlatform;
      in {
        packages.${buildPlatform} = lib.flip lib.mapAttrs inputs.self.nixosConfigurations (_: nixos:
          nixos.config.system.build.toplevel
        );
        nixosConfigurations = {
          "installer-${hostSystem.cpu.name}" = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs lib;
            };
            modules = [
              ({modulesPath, config, lib, pkgs, ...}: {
                boot.isContainer = true;
                users.users.root.hashedPassword = "";
              })
              {
                nixpkgs = {
                  inherit pkgs;
                  inherit buildPlatform;
                  hostPlatform = buildPlatform;
                };
              }
              inputs.self.nixosModules.profiles.nix
            ];
          };
        };
      }
    );
}
