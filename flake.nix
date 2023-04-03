{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nix-monitored = {
      url = "github:ners/nix-monitored";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    macname.url = "github:vkleen/macname";
  };

  outputs = inputs:
    let
      lib = import ./lib { inherit inputs; };
      buildPlatforms = [ "x86_64-linux" "aarch64-linux" "riscv64-linux" "powerpc64le-linux" ];
    in
    {
      inherit lib;
      nixosModules = lib.findModules ./modules;
      overlays = lib.mapAttrs (_: v: import v) (lib.findModules ./overlays);
    } // lib.foreach buildPlatforms (buildPlatform:
      let
        hostSystem = lib.systems.parse.mkSystemFromString buildPlatform;

        mkNixosConfig = hostName: modules: inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs lib;
            system = {
              inherit hostName;
              computeHostId = inputs.macname.computeHostId.${buildPlatform};
            };
          };
          inherit modules;
        };
      in
      {
        packages.${buildPlatform} = (lib.flip lib.mapAttrs inputs.self.nixosConfigurations (_: nixos:
          nixos.config.system.build.toplevel
        )) // {
          inherit (inputs.macname.packages.${buildPlatform}) macname;
        };

        nixosConfigurations = {
          "installer-${hostSystem.cpu.name}" = mkNixosConfig "hydrogen" ([
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
            ({ config, inputs, ... }: {
              nixpkgs = {
                overlays = lib.attrValues inputs.self.overlays;
                hostPlatform = lib.recursiveUpdate
                  (lib.systems.elaborate buildPlatform)
                  { linux-kernel.target = "zImage"; };
              };
            })
          ] ++ lib.attrValues {
            inherit (inputs.self.nixosModules)
              core;
            inherit (inputs.self.nixosModules.profiles)
              chrony doas nix latest-linux;
          });
        };
      }
    );
}
