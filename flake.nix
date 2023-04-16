{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nix-monitored = {
      url = "github:ners/nix-monitored";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    macname.url = "github:vkleen/macname";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = inputs:
    let
      lib = import ./lib { inherit inputs; };
      platforms = [ "x86_64-linux" "aarch64-linux" "riscv64-linux" "powerpc64le-linux" ];

      mkNixosConfig = lib.makeOverridable
        (
          { hostName
          , hostPlatform
          , buildPlatform ? hostPlatform
          , specialArgs ? { }
          , modules
          , ...
          }: inputs.nixpkgs.lib.nixosSystem {
            specialArgs = lib.recursiveUpdate
              {
                inherit inputs lib;
                system = {
                  inherit hostName hostPlatform;
                  computeHostId = inputs.macname.computeHostId.${buildPlatform};
                };
              }
              specialArgs;
            modules = [ inputs.self.nixosModules.profiles.core ] ++ modules;
          }
        );
    in
    {
      inherit lib;
      nixosModules = lib.findModules ./modules;
      overlays = lib.mapAttrsRecursive (_: v: import v) (lib.findModules ./overlays) // {
        nixpkgsFun = (final: prev: {
          nixpkgsFun = newArgs:
            import "${inputs.nixpkgs}" ({
              localSystem = final.stdenv.buildPlatform;
              inherit (final) config;
              overlays = lib.attrValuesRecursive inputs.self.overlays;
            } // newArgs);
        });
      };
    } // lib.foreach platforms (buildPlatform: {
      packages.${buildPlatform} = (lib.flip lib.mapAttrs inputs.self.nixosConfigurations (_: nixos:
        (nixos.override { inherit buildPlatform; }).config.system.build.toplevel
      )) // {
        inherit (inputs.macname.packages.${buildPlatform}) macname;
      };
    }) // lib.recursiveUpdateUntil (path: _: _: lib.length path == 2 && lib.head path == "nixosConfigurations")
      (
        lib.foreach platforms (hostPlatform: (
          let
            hostCpu = (lib.systems.parse.mkSystemFromString hostPlatform).cpu.name;
          in
          {
            nixosConfigurations = {
              "installer-${hostCpu}" = mkNixosConfig {
                hostName = "hydrogen";
                inherit hostPlatform;
                modules =
                  [
                    {
                      system.macnameNamespace = "nixos-installers.kleen.org";
                      system.stateVersion = "23.05";
                    }
                    {
                      users.users.root.hashedPassword = "";
                      fileSystems."/" = {
                        device = "/dev/disk/by-label/NIXOS";
                        autoResize = true;
                        fsType = "f2fs";
                      };
                      boot.loader.grub.device = "nodev";
                    }
                  ] ++ lib.attrValues {
                    inherit (inputs.self.nixosModules)
                      chrony
                      doas
                      latest-linux
                      nix
                      ssh
                      ;
                  };
              };
            };
          }
        ))
      )
      {
        nixosConfigurations = lib.mapAttrsRecursive (_: v: import v { inherit mkNixosConfig lib inputs; })
          (lib.findModules ./hosts);
      };
}
