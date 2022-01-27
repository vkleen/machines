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

    bufferline = { url = github:akinsho/bufferline.nvim; flake = false; };
    clever-f = { url = github:rhysd/clever-f.vim; flake = false; };
    cmp-buffer = { url = github:hrsh7th/cmp-buffer; flake = false; };
    cmp-nvim-lsp = { url = github:hrsh7th/cmp-nvim-lsp; flake = false; };
    fterm = { url = github:numtostr/FTerm.nvim; flake = false; };
    gitsigns = { url = github:lewis6991/gitsigns.nvim; flake = false; };
    lualine = { url = github:hoob3rt/lualine.nvim; flake = false; };
    nvim-cmp = { url = github:hrsh7th/nvim-cmp; flake = false; };
    nvim-colorizer = { url = github:norcalli/nvim-colorizer.lua; flake = false; };
    nvim-hlslens = { url = github:kevinhwang91/nvim-hlslens; flake = false; };
    nvim-lspconfig = { url = github:neovim/nvim-lspconfig; flake = false; };
    nvim-treesitter-context = { url = github:romgrk/nvim-treesitter-context; flake = false; };
    nvim-ts-rainbow = { url = github:p00f/nvim-ts-rainbow; flake = false; };
    plenary-nvim = { url = github:vkleen/plenary.nvim; flake = false; };
    rust-tools = { url = github:simrat39/rust-tools.nvim; flake = false; };
    telescope-ghq = { url = github:nvim-telescope/telescope-ghq.nvim; flake = false; };
    telescope-lsp-handlers = { url = github:gbrlsnchs/telescope-lsp-handlers.nvim; flake = false; };
    telescope-zoxide = { url = github:jvgrootveld/telescope-zoxide; flake = false; };
    vim-vsnip-integ = { url = github:hrsh7th/vim-vsnip-integ; flake = false; };
    vim-vsnip = { url = github:hrsh7th/vim-vsnip; flake = false; };
    which-key-nvim = { url = github:folke/which-key.nvim; flake = false; };
  };

  outputs = { self, ... }@inputs: let
    inherit (inputs.utils.lib)
      allSystems
      attrNames
      attrValues
      concatMap
      fakeHash
      filterAttrs
      forAllSystems
      fromJSON
      genAttrs
      getAttrs
      isDerivation
      onlySystems
      readFile
      strings
      ;

    rtpPath = ".";

    addRtp = path: derivation:
      derivation // { rtp = "${derivation}/${path}"; };

    vimPlugin = pkgs: ref: vimPluginSubdir pkgs ref "";
    vimPluginSubdir = pkgs: ref: d: addRtp "${rtpPath}/${ref}" (pkgs.stdenv.mkDerivation {
      name = "vimplugin-${strings.sanitizeDerivationName ref}";
      unpackPhase = ":";
      buildPhase = ":";
      configurePhase = ":";
      installPhase = ''
        runHook preInstall
        target="$out/${rtpPath}"
        mkdir -p "$target"
        cp -r "${inputs."${ref}".outPath}/${d}/"* "$target"
        runHook postInstall
      '';
    });


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
        flake="''${PWD}"
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
          jq --arg newhash "''${newhash}" '."neovide-cargoHash" = $newhash' <"''${flake}/hashes.json"
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
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      subdir = n: d: {
        outPath = "${builtins.toString inputs."${n}".outPath}/${d}";
      };
    in genAttrs [
        "bufferline"
        "clever-f"
        "cmp-buffer"
        "cmp-nvim-lsp"
        "fterm"
        "gitsigns"
        "lualine"
        "nvim-cmp"
        "nvim-colorizer"
        "nvim-hlslens"
        "nvim-lspconfig"
        "nvim-treesitter-context"
        "nvim-ts-rainbow"
        "plenary-nvim"
        "rust-tools"
        "telescope-ghq"
        "telescope-lsp-handlers"
        "telescope-zoxide"
        "vim-vsnip"
        "vim-vsnip-integ"
        "which-key-nvim"
      ] (vimPlugin pkgs));

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
    checks = self.packages;
  };
}
