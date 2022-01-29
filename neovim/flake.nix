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

    updateScript = s: let
      pkgs = pkgset.${s};
    in pkgs.writeShellApplication {
      name = "update-hashes";
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
          jq --arg newhash "''${newhash}" '."neovide-cargoHash" = $newhash' <"${./hashes.json}"
        else
          exit 1
        fi
      '';
    };
  in {
    overlays = {
      neovide-master = import ./neovide-master.nix {
        inherit (inputs) neovide-src;
        inherit (fromJSON (readFile ./hashes.json)) neovide-cargoHash;
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

    apps = forAllSystems (system: {
      update-hashes = {
        type = "app";
        program = "${updateScript system}/bin/update-hashes";
      };
    });

    packages = forAllSystems (system:
      let
        pkgs = pkgset."${system}";
        pkgNames = concatMap (o: attrNames (o pkgs pkgs)) (attrValues self.overlays);
      in filterAttrs (_: isDerivation) (getAttrs pkgNames pkgset."${system}"));

    checks = forAllSystems (system: 
      self.packages.${system} // (filterAttrs (_: isDerivation) self.vimPlugins.${system}));
  };
}
