{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    trilby.url = "github:ners/trilby";
    macname.url = "github:vkleen/macname";
    nix-monitored.url = "github:ners/nix-monitored";
    impermanence.url = "github:nix-community/impermanence";
    agenix.url = "github:ryantm/agenix";
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          import trilby.nixpkgs {
            inherit overlays;
            system = trilby.hostPlatform;
          };

        nixosSystem = args: prev.nixosSystem (args // {
          modules = [
            inputs.agenix.nixosModules.default
            inputs.agenix-rekey.nixosModules.default
            {
              config.age.rekey.masterIdentities = [ ./secrets/vkleen.age ];
            }
          ] ++ args.modules;
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
    in
    lib.recursiveConcat [
      { inherit lib; }

      {
        agenix-rekey = inputs.agenix-rekey.configure {
          userFlake = inputs.self;
          nodes = inputs.self.nixosConfigurations;
        };
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
          devShells.${buildPlatform} = {
            default = pkgs.mkShell {
              packages = [
                pkgs.nixpkgs-fmt
                pkgs.age
                inputs.agenix-rekey.packages.${buildPlatform}.agenix-rekey
                inputs.macname.packages.${buildPlatform}.macname
                (pkgs.python3.withPackages (ps: with ps; [ matplotlib ]))
              ];
            };
          };
        }
      ))
    ];
}
