{
  description = "VKleen's flakey nixos configuration";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "vkleen";
      repo = "nixpkgs";
      ref = "local";
    };
    nixpkgs-power9 = {
      type = "github";
      owner = "vkleen";
      repo = "nixpkgs";
      ref = "local-power9";
    };
    nixos-rocm-power9 = {
      type = "github";
      owner = "vkleen";
      repo = "nixos-rocm";
      ref = "master";
      flake = false;
    };
    nixpkgs-wayland = {
      type = "github";
      owner = "colemickens";
      repo = "nixpkgs-wayland";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      type = "github";
      owner = "Mic92";
      repo = "sops-nix";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      type = "github";
      owner = "serokell";
      repo = "deploy-rs";
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    freecad-src = {
      type = "github";
      owner = "realthunder";
      repo = "FreeCAD";
      ref = "master";
      flake = false;
    };
  };

  outputs = { self, ...}@inputs:
    let
      inherit (builtins) attrNames attrValues elemAt;
      inherit (inputs.nixpkgs) lib;
      utils = import ./utils { inherit lib; };
      inherit (utils) recImport overrideModule;
      inherit (lib) nixosSystem mkIf splitString filterAttrs listToAttrs mapAttrsToList nameValuePair concatMap composeManyExtensions mapAttrs mapAttrs' recursiveUpdate concatLists concatStrings hasPrefix;

      systemIsPower9 = hasPrefix "powerpc64le";

      legacyPackages = recursiveUpdate inputs.nixpkgs.legacyPackages
                         (filterAttrs (n: _: systemIsPower9 n) inputs.nixpkgs-power9.legacyPackages);

      mkNixosConfiguration = dir: path: hostName: nixosSystem rec {
        specialArgs = {
          flake = self;
          flakeInputs = inputs;
        };
        modules =
          let
            defaultProfiles = with self.nixosModules.systemProfiles;
              [ core
              ];

            local = "${toString dir}/${path}";
            argsModule = { config, ...}: {
              _module.args = {
                customUtils = utils;
                inherit hostName;
                input-pkgs =
                  if hasPrefix "powerpc64le" config.nixpkgs.system
                  then inputs.nixpkgs-power9
                  else inputs.nixpkgs;
              };
            };
            addHomeManagerDefaults = accountName: v:
              let
                accountName' = splitString "@" accountName;
                userName = elemAt accountName' 0;
              in [
                ({pkgs, config, ...}: {
                  home-manager.users.${userName} =
                    { programs.home-manager = {
                        enable = true;
                      };
                      manual.manpages.enable = true;
                      _module.args.pkgs = lib.mkForce pkgs;
                      _module.args.nixos = config;
                    };
                })
                v
              ];
            accountModules = concatLists (mapAttrsToList addHomeManagerDefaults
                                           (filterAttrs accountMatchesHost self.nixosModules.accounts));
            accountMatchesHost = n: _v:
              let
                accountName' = splitString "@" n;
                hostName' = elemAt accountName' 1;
              in hostName' == hostName;
          in [ argsModule ] ++ defaultProfiles ++ [ local ] ++ accountModules ++ [ self.nixosModules.users.root ];
      };

      mkSystemProfile = dir: path: profileName: {
        imports = [ "${toString dir}/${path}" ];
        config = {
          system.profiles = [profileName];
        };
      };

      mkUserModule = dir: path: userName:
        overrideModule (import "${toString dir}/${path}")
                       (inputs: inputs // { inherit userName; })
                       (outputs: { _file = "${toString dir}/${path}"; } // outputs);

      mkAccountModule = dir: path: accountName:
        let
          accountName' = splitString "@" accountName;
          userName = elemAt accountName' 0;
        in overrideModule
             (import "${toString dir}/${path}")
             (inputs: inputs // { inherit userName; })
             (outputs: { _file = "${toString dir}/${path}"; }
                       // outputs
                       // { imports = [self.nixosModules.users.${userName}] ++ (outputs.imports or []); });

      forAllSystems = f: mapAttrs f legacyPackages;

      activateHomeManagerConfigurations = forAllSystems (system: _pkgs:
        mapAttrs' (configName: hmConfig:
                    nameValuePair "${configName}-activate"
                                  { type = "app"; program = "${hmConfig.activationPackage}/bin/activate"; })
                  self.homeManagerConfigurations);
      activateNixosConfigurations = forAllSystems (system: _pkgs:
        mapAttrs' (hostName: nixosConfig:
                    nameValuePair "${hostName}-activate"
                                  { type = "app"; program = "${nixosConfig.config.system.build.toplevel}/bin/switch-to-configuration"; })
                  self.nixosConfigurations);
    in
      {
        nixosModules =
          let modulesAttrs = recImport { dir = ./modules; };
              systemProfiles = recImport rec { dir = ./system-profiles; _import = mkSystemProfile dir; };
              users = recImport rec { dir = ./users; _import = mkUserModule dir; };
              accounts = recImport rec { dir = ./accounts; _import = mkAccountModule dir; };
          in modulesAttrs // { inherit systemProfiles users accounts; };

        nixosConfigurations = recImport rec { dir = ./hosts; _import = mkNixosConfiguration dir; };

        homeManagerConfigurations =
          listToAttrs (concatMap ({hostName, users}:
                                   mapAttrsToList (userName: homeConfig:
                                                    nameValuePair "${userName}@${hostName}" homeConfig)
                                                  users)
                                 (mapAttrsToList (hostName: nixosConfig:
                                                   { inherit hostName;
                                                     users = nixosConfig.config.home-manager.users;
                                                   })
                                                 self.nixosConfigurations));

        userProfiles = recImport rec { dir = ./user-profiles; };

        overlay = import ./pkgs;
        overlays = recImport { dir = ./overlays; } //
          { pkgs = self.overlay;

            nixos-rocm-power9 = import inputs.nixos-rocm-power9;
            nixpkgs-wayland = inputs.nixpkgs-wayland.overlay;
            sources = _: _: {
              inherit (inputs) freecad-src;
            };
          };
        overlays-path = forAllSystems (system: _:
          self.legacyPackages."${system}".writeText "overlays.nix" ''
            [
              ${concatStrings
                (attrValues
                  (recImport rec {
                    dir = ./overlays;
                    _import = n: _: "(import ${"${./overlays}/${n}"})";
                  }))
              }
              (import ${./pkgs})
              (import ${builtins.toString inputs.nixpkgs-wayland})
              (import ${builtins.toString inputs.nixos-rocm-power9})
            ]
          '');

        legacyPackages = forAllSystems (system: systemPkgs:
          import systemPkgs.path {
            inherit system;
            overlays = attrValues self.overlays;
            config = {
              allowUnfree = true;
            };
          });

        apps = recursiveUpdate activateNixosConfigurations activateHomeManagerConfigurations;

        devShell = forAllSystems (system: _:
          import ./shell.nix { pkgs = self.legacyPackages.${system};
                               extra-inputs = [ inputs.deploy-rs.packages.${system}.deploy-rs ];
                             });

        defaultTemplate = {
          path = ./.;
          description = "A flakey nixos configuration";
        };
      };
}
