{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nix-monitored = {
      url = "github:ners/nix-monitored";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    macname = {
      url = "github:vkleen/macname";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/17198cf5ae27af5b647c7dac58d935a7d0dbd189";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          }:
          let
            nixpkgs-patched = inputs.nixpkgs.legacyPackages.${buildPlatform}.applyPatches {
              name = "nixpkgs";
              src = inputs.nixpkgs;
              patches = [ ./nixpkgs-power9.patch ];
            };
            nixpkgs-power9 = inputs.nixpkgs.lib.fix
              (self:
                (import "${nixpkgs-patched}/flake.nix").outputs {
                  inherit self;
                }) // { outPath = "${nixpkgs-patched}"; };

            nixpkgs =
              if hostPlatform != "powerpc64le-linux"
              then inputs.nixpkgs
              else nixpkgs-power9;
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = lib.recursiveUpdate
              {
                inherit lib;
                inputs = inputs // {
                  inherit nixpkgs;
                };
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
      overlays = lib.mapAttrsRecursive (_: v: import v) (lib.findModules ./overlays);
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
        nixosConfigurations = lib.mapAttrsRecursive
          (_: v: import v {
            inherit mkNixosConfig lib;
            inherit (inputs) self;
          })
          (lib.findModules ./hosts);
      };
}
