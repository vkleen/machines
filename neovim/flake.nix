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

    neovide-src = {
      url = github:Kethku/neovide?rev=8a7c2a00dc4be834215e3f21f5a0c9dd53646998;
      flake = false;
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

    updateCargoHashesScript = s: let
      pkgs = pkgset.${s};
    in pkgs.writeShellApplication {
      name = "update-cargo-hashes";
      runtimeInputs = [ pkgs.nix pkgs.jq pkgs.coreutils ];
      text = ''
        flake="${./.}"
        if [[ "''${#}" -ge 1 ]]; then
          flake="''${1}"
        fi

        function getNewHash() {
          (nix build --impure --expr '(builtins.getFlake "'"''${flake}"'").packages."${s}".neovide.cargoDeps.overrideAttrs (_: { outputHash = "${fakeHash}"; })' 2>&1 || true) | \
            grep 'got:' | \
            cut -d':' -f2 | \
            tr -d ' '
        }

        newhash="$(getNewHash)"
        if [[ -n "''${newhash}" ]]; then
          jq --arg newhash "''${newhash}" '."neovide-cargoHash" = $newhash' <"${./cargoHashes.json}"
        else
          exit 1
        fi
      '';
    };

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
        ${updateCargoHashesScript s}/bin/update-cargo-hashes > cargoHashes.json
      '';
    };

    homeModule = s: {
      imports = [ ./configuration/home-module.nix ];
      _module.args.neovim = {
        neovim-unwrapped = self.packages.${s}.neovim-unwrapped;
        neovide = self.packages.${s}.neovide;
        vimPlugins = self.vimPlugins.${s};
      };
    };
  in {
    overlays = {
      neovide-master = import ./neovide-master.nix {
        inherit (inputs) neovide-src;
        inherit (fromJSON (readFile ./cargoHashes.json)) neovide-cargoHash;
      };
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
      update-cargo-hashes = {
        type = "app";
        program = "${updateCargoHashesScript system}/bin/update-cargo-hashes";
      };

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
