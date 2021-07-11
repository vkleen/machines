{
  description = "vkleen's machines";

  inputs = {
    nixpkgs.url = "github:vkleen/nixpkgs/local";
    nixpkgs-power9.url = "github:vkleen/nixpkgs/local-power9";
    nixpkgs-riscv.url = "github:vkleen/nixpkgs/local-riscv";
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
    freecad-src = {
      url = "github:realthunder/FreeCAD";
      flake = false;
    };
    freecad-assembly3-src = {
      url = "github:realthunder/FreeCAD_assembly3";
      flake = false;
    };
    kicad-src = {
      url = "git+https://gitlab.com/kicad/code/kicad.git";
      flake = false;
    };
    hledger-src = {
      url = "github:vkleen/hledger";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-power9, nixpkgs-riscv, nixos-rocm-power9, home-manager, nixpkgs-wayland, ... }:
    let
      inherit (builtins) attrValues attrNames readDir;
      inherit (nixpkgs) lib;
      inherit (lib) removeSuffix hasSuffix recursiveUpdate genAttrs filterAttrs;

      utils = import ./lib/utils.nix { inherit lib; };
      inherit (utils) pathsToImportedAttrs pathsToImportedAttrs';

      forAllSystems' = genAttrs [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = genAttrs [ "x86_64-linux" "aarch64-linux" "powerpc64le-linux" "riscv64-linux" ];

      pkgsImport = system: pkgs:
        import pkgs {
          inherit system;
          overlays = attrValues self.overlays;
          config = { allowUnfree = true; allowUnsupportedSystem = true; };
        };

      pkgsImportCross = localSystem: crossSystem: pkgs:
        import pkgs {
          inherit localSystem crossSystem;
          overlays = attrValues self.overlays;
          config = { allowUnfree = true; allowUnsupportedSystem = true; };
        };

      pkgset = { inherit pkgsImport; }
        // (forAllSystems' (s: pkgsImport s nixpkgs))
        // { "powerpc64le-linux" = (pkgsImport "powerpc64le-linux" nixpkgs-power9).extend (import nixos-rocm-power9); }
        // { "riscv64-linux" = pkgsImport "riscv64-linux" nixpkgs-riscv; };

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
             sources = _: _: {
               inherit (inputs) freecad-src freecad-assembly3-src kicad-src hledger-src;
             };
           };

      overlays-path = forAllSystems (s:
        pkgset."${s}".writeText "overlays.nix" ''
          [
            (import ${./pkgs})
            (import ${builtins.toString nixpkgs-wayland})
          ]
        '');

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
            profiles = pathsToImportedAttrs profilesList;
          };
        in
          recursiveUpdate modulesAttrs profilesAttrs;
    };
}
