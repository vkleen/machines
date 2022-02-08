{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    utils.url = path:../utils-flake;
    utils.inputs.nixpkgs.follows = "nixpkgs";

    neovim-flake = {
      url = github:neovim/neovim?dir=contrib;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly = {
      url = github:nix-community/neovim-nightly-overlay;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        neovim-flake.follows = "neovim-flake";
      };
    };

    plugins.url = path:./plugins;
    plugins.inputs = {
      utils.follows = "utils";
      nixpkgs.follows = "nixpkgs";
      neovim-flake.follows = "neovim-flake";
    };
  };

  outputs = { self, ... }@inputs: let
    inherit (inputs.utils.lib)
      allSystems
      attrNames
      attrValues
      concatMap
      extends
      fakeHash
      filterAttrs
      forAllSystems
      fromJSON
      genAttrs
      getAttrs
      getBin
      isDerivation
      makeExtensible
      mapAttrs
      onlySystems
      optional
      readFile
      strings
      ;

    pkgsImport = system: pkgs:
      import pkgs {
        inherit system;
        overlays = attrValues self.overlays;
        config = { allowUnfree = true; allowUnsupportedSystem = true; };
      };
    pkgset = forAllSystems (s: pkgsImport s inputs.nixpkgs);

    updatePluginsScript = s: let
      pkgs = pkgset.${s};
    in pkgs.writeShellApplication {
      name = "update-plugins";
      runtimeInputs = [ pkgs.nix pkgs.coreutils ];
      text = ''
        pushd plugins
        nix flake update --inputs-from path:../.
        nix run .#update-grammars
        popd
        nix flake lock --update-input plugins
      '';
    };

    updateScript = s: let
      pkgs = pkgset.${s};
    in pkgs.writeShellApplication {
      name = "update";
      runtimeInputs = [ pkgs.nix pkgs.coreutils ];
      text = ''
        nix flake update
        ${updatePluginsScript s}/bin/update-plugins
      '';
    };

    homeModule = s: {
      imports = [ ./configuration/home-module.nix ];
      _module.args.neovim = {
        neovim-unwrapped = self.packages.${s}.neovim-unwrapped;
        vimPlugins = self.vimPlugins.${s};
      };
    };
  in {
    overlays = {
      neovim-nightly = onlySystems allSystems (final: prev: {
        neovim-unwrapped = (inputs.neovim-nightly.overlay final prev).neovim-unwrapped;
      });
    };

    vimPlugins = forAllSystems (system: 
      let
        pkgs = pkgset.${system};
      in makeExtensible (extends
            (inputs.plugins.vimPluginsOverrides pkgs)
            (inputs.plugins.vimPlugins pkgs)));

    homeManagerModules = forAllSystems (s: {
      neovim-config = homeModule s;
    });

    apps = forAllSystems (system: {
      update-plugins = {
        type = "app";
        program = "${updatePluginsScript system}/bin/update-plugins";
      };

      update = {
        type = "app";
        program = "${updateScript system}/bin/update";
      };
    });

    packages = forAllSystems (system:
      let
        pkgs = pkgset."${system}";
        pkgNames = concatMap (o: attrNames (o pkgs pkgs)) (attrValues self.overlays);
      in filterAttrs (_: isDerivation) (getAttrs pkgNames pkgset."${system}"));

    checks = forAllSystems (system: 
      self.packages.${system} //
      (filterAttrs (_: isDerivation) self.vimPlugins.${system}) //
      { nvim-treesitter = self.vimPlugins.${system}.nvim-treesitter.withPlugins (gs: with gs; [c bash]); } //
      inputs.plugins.checks.${system});
  };
}
