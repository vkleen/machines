{
  description = "vkleen's machines";

  inputs = {
    nixpkgs.url = "github:vkleen/nixpkgs/local";
    nixpkgs-power9.url = "github:vkleen/nixpkgs/local-power9";
    nixos-rocm-power9 = {
      url = "github:vkleen/nixos-rocm";
      flake = false;
    };
    nixpkgs-wayland = {
      url = "github:colemickens/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:rycee/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-power9, nixos-rocm-power9, home-manager, nixpkgs-wayland, ... }:
    let
      inherit (builtins) attrValues attrNames readDir;
      inherit (nixpkgs) lib;
      inherit (lib) removeSuffix hasSuffix recursiveUpdate genAttrs filterAttrs;

      utils = import ./lib/utils.nix { inherit lib; };
      inherit (utils) pathsToImportedAttrs pathsToImportedAttrs';

      forAllSystems = genAttrs [ "x86_64-linux" "aarch64-linux" ];

      pkgsImport = system: pkgs:
        import pkgs {
          inherit system;
          overlays = attrValues self.overlays;
          config = { allowUnfree = true; };
        };

      pkgset = { inherit pkgsImport; }
        // (forAllSystems (s: pkgsImport s nixpkgs))
        // { "powerpc64le-linux" = (pkgsImport "powerpc64le-linux" nixpkgs-power9).extend (import nixos-rocm-power9); };

      pkgSources = {
        local = nixpkgs;
        local-power9 = nixpkgs-power9;
      };
    in {
      overlay = import ./pkgs;

      overlays =
        let
          overlayDir = ./overlays;
          fullPath = name: overlayDir + "/${name}";
          filteredPaths = filterAttrs (n: v: hasSuffix ".nix" n) (readDir overlayDir);
          overlayPaths = map fullPath (attrNames filteredPaths);
        in pathsToImportedAttrs overlayPaths // {
             nixpkgs-wayland = nixpkgs-wayland.overlay;
           };

      packages = forAllSystems (s:
        let
          pkgs = pkgset."${s}";
        in self.overlay pkgs pkgs
      );

      devShell = forAllSystems (s: import ./shell.nix { pkgs = pkgset."${s}"; });

      nixosConfigurations =
        import ./hosts (recursiveUpdate inputs {
          inherit lib pkgset pkgSources utils;
        });

      nixosModules =
        let
          moduleList = import ./modules/list.nix;
          modulesAttrs = pathsToImportedAttrs moduleList;

          profilesList = import ./profiles/list.nix;
          profilesAttrs = {
            profiles = pathsToImportedAttrs' {
              paths = profilesList;
              _import = p: import p self;
            };
          };
        in
          recursiveUpdate modulesAttrs profilesAttrs;
    };
}
