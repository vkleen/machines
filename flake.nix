{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    trilby = {
      url = "github:ners/trilby";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
      inputs."nixpkgs-23.11".follows = "nixpkgs";
    };
    macname.url = "github:vkleen/macname";
    nix-monitored.url = "github:ners/nix-monitored";
    impermanence.url = "github:nix-community/impermanence";
    agenix.url = "github:ryantm/agenix";
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    libgphoto2 = {
      url = "github:gphoto/libgphoto2";
      flake = false;
    };
    hyprland.url = "github:hyprwm/hyprland";
    hyprlang.url = "github:hyprwm/hyprlang";
    hypridle.url = "github:hyprwm/hypridle";
  };

  outputs = inputs:
    let
      lib = inputs.trilby.lib.extend (final: prev: {
        pkgsFor = t:
          let
            trilby = final.trilbyConfig t;
            overlaySrcs = final.attrValues (final.recursiveUpdate
              inputs.self.nixosModules.trilby.overlays
              inputs.self.nixosModules.overlays);
            overlays = map
              (o: (if final.isFunction o then o else import o) {
                inherit inputs lib trilby;
                overlays = overlaySrcs;
              })
              overlaySrcs;
          in
          import trilby.nixpkgs ({
            inherit overlays;
            system = trilby.hostPlatform;
          } // final.optionalAttrs (trilby.hostPlatform == "powerpc64le-linux") {
            config.allowUnsupportedSystem = true;
          });

        nixosSystem = args: prev.nixosSystem (args // {
          modules = [
            inputs.agenix.nixosModules.default
            inputs.agenix-rekey.nixosModules.default
            {
              config.age.rekey.masterIdentities = [ ./secrets/vkleen.age ];
            }
          ] ++ args.modules;
          specialArgs = {
            inherit inputs lib;
          } // args.specialArgs;
        });
      });
      platforms = builtins.attrNames inputs.nixpkgs.legacyPackages;

      hosts = lib.findModules ./hosts;

      wrappedTrilbyInputs = inputs.trilby.inputs // {
        self = inputs.trilby // {
          nixosModules = lib.mapAttrsRecursive (_: wrapTrilbyModule) inputs.trilby.nixosModules;
        };
      };
      wrapTrilbyModule = m:
        let
          module = import m;
        in
        if !lib.isFunction module
        then module
        else
          lib.setFunctionArgs
            (args: module (args // { inputs = wrappedTrilbyInputs; }))
            (lib.functionArgs module);

      utils = lib.pipe ./utils [
        lib.findModules
        (lib.mapAttrsRecursive (_: f: import f { inherit inputs lib; }))
      ];
    in
    lib.recursiveConcat [
      { inherit lib utils; }

      {
        agenix-rekey = lib.foreach platforms (system: {
          apps.${system} = lib.genAttrs [ "edit" "generate" "rekey" ] (app:
            import "${inputs.agenix-rekey}/apps/${app}.nix" {
              userFlake = inputs.self;
              nodes = inputs.self.nixosConfigurations;
              pkgs = lib.pkgsFor {
                buildPlatform = system;
                hostPlatform = system;
              };
            }
          );
        });
      }

      {
        nixosModules = lib.recursiveConcat [
          {
            trilby = wrappedTrilbyInputs.self.nixosModules;
          }
          (lib.findModules ./modules)
        ];
      }

      (lib.foreach platforms (buildPlatform:
        (lib.foreach (lib.flattenAttrs (lib.constr true) hosts) (nv:
          let
            name = lib.last nv.name;
            host = {
              inherit name;
            } // (import nv.value { inherit name lib inputs buildPlatform; });
          in
          {
            nixosConfigurations.${host.name} = host.system;
            packages.${buildPlatform}.${host.name} = host.output;
          }
        ))
      ))

      (lib.foreach platforms (buildPlatform:
        let
          pkgs = lib.pkgsFor {
            inherit buildPlatform;
            hostPlatform = buildPlatform;
          };
        in
        {
          formatter.${buildPlatform} = pkgs.nixpkgs-fmt;
          packages.${buildPlatform}.pkgs = pkgs;
          devShells.${buildPlatform} =
            let
              agenix-pkgs = pkgs.extend inputs.agenix-rekey.overlays.default;
              macname-pkgs = pkgs.extend inputs.macname.overlays.default;
            in
            {
              default = pkgs.mkShell {
                packages = [
                  pkgs.nixpkgs-fmt
                  pkgs.age
                  agenix-pkgs.agenix-rekey
                  macname-pkgs.macname
                  (pkgs.python3.withPackages (ps: with ps; [ matplotlib ]))
                ];
              };
            };
        }
      ))
    ];
}
