{
  description = "gkleen's machines";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "master";
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
  };

  outputs = { self, nixpkgs, home-manager, sops-nix }@inputs:
    let
      inherit (builtins) attrNames attrValues elemAt;
      inherit (nixpkgs) lib;
      utils = import ./utils { inherit lib; };
      inherit (utils) recImport overrideModule;
      inherit (lib) nixosSystem mkIf splitString filterAttrs listToAttrs mapAttrsToList nameValuePair concatMap composeManyExtensions mapAttrs mapAttrs' recursiveUpdate;

      mkNixosConfiguration = dir: path: hostName: nixosSystem rec {
        specialArgs = {
          flake = self;
          flakeInputs = inputs;
          path = toString ./.;
        };
        modules =
          let
            extraModules = [
              sops-nix.nixosModules.sops
              home-manager.nixosModules.home-manager
            ];
            defaultProfiles = with self.nixosModules.systemProfiles; [core];
            local = "${toString dir}/${path}";
            global._module.args = {
              customUtils = utils;
              inherit hostName;
            };
            accountModules = attrValues (filterAttrs accountMatchesHost self.nixosModules.accounts);
            accountMatchesHost = n: _v:
              let
                accountName' = splitString "@" n;
                hostName' = elemAt accountName' 1;
              in hostName' == hostName;
          in extraModules ++ [ global ] ++ defaultProfiles ++ [ local ] ++ accountModules;
      };

      mkSystemProfile = dir: path: profileName: {
        imports = [ "${toString dir}/${path}" ];
        config = {
          system.profiles = [profileName];
        };
      };

      mkUserModule = dir: path: userName: overrideModule (import "${toString dir}/${path}") (inputs: inputs // { inherit userName; }) (outputs: { _file = "${toString dir}/${path}"; } // outputs);

      mkAccountModule = dir: path: accountName:
        let
          accountName' = splitString "@" accountName;
          userName = elemAt accountName' 0;
        in overrideModule (import "${toString dir}/${path}") (inputs: inputs // { inherit userName; }) (outputs: { _file = "${toString dir}/${path}"; } // outputs // { imports = [self.nixosModules.users.${userName}] ++ (outputs.imports or []); });

      forAllSystems = f: mapAttrs f nixpkgs.legacyPackages;

      activateHomeManagerConfigurations = forAllSystems (system: _pkgs: mapAttrs' (configName: hmConfig: nameValuePair "${configName}-activate" { type = "app"; program = "${hmConfig.activationPackage}/bin/activate"; }) self.homeManagerConfigurations);
      activateNixosConfigurations = forAllSystems (system: _pkgs: mapAttrs' (hostName: nixosConfig: nameValuePair "${hostName}-activate" { type = "app"; program = "${nixosConfig.config.system.build.toplevel}/bin/switch-to-configuration"; }) self.nixosConfigurations);
    in
      {
        nixosModules =
          let modulesAttrs = recImport { dir = ./modules; };
              systemProfiles = recImport rec { dir = ./system-profiles; _import = mkSystemProfile dir; };
              userProfiles = recImport rec { dir = ./user-profiles; };
              users = recImport rec { dir = ./users; _import = mkUserModule dir; };
              accounts = recImport rec { dir = ./accounts; _import = mkAccountModule dir; };
          in modulesAttrs // { inherit systemProfiles userProfiles users accounts; };
        nixosConfigurations = recImport rec { dir = ./hosts; _import = mkNixosConfiguration dir; };

        homeManagerConfigurations = listToAttrs (concatMap ({hostName, users}: mapAttrsToList (userName: homeConfig: nameValuePair "${userName}@${hostName}" homeConfig) users) (mapAttrsToList (hostName: nixosConfig: { inherit hostName; users = nixosConfig.config.home-manager.users; }) (self.nixosConfigurations)));

        overlay = import ./pkgs;
        overlays = recImport { dir = ./overlays; } // { pkgs = self.overlay; };

        packages = forAllSystems (system: systemPkgs: composeManyExtensions (attrValues self.overlays) (self.legacyPackages.${system}) systemPkgs);

        legacyPackages = forAllSystems (system: systemPkgs: recursiveUpdate systemPkgs self.packages.${system});

        apps = recursiveUpdate activateNixosConfigurations activateHomeManagerConfigurations;

        devShell = forAllSystems (system: systemPkgs: import ./shell.nix { pkgs = self.legacyPackages.${system}; });
      };
}
