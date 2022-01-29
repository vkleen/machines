{
  inputs = {
    utils.url = path:../../utils-flake;
    nixpkgs.url = github:NixOS/nixpkgs;

    neovim-flake = {
      url = github:neovim/neovim?dir=contrib;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vimplugin-bufferline = { url = github:akinsho/bufferline.nvim; flake = false; };
    vimplugin-clever-f = { url = github:rhysd/clever-f.vim; flake = false; };
    vimplugin-cmp-buffer = { url = github:hrsh7th/cmp-buffer; flake = false; };
    vimplugin-cmp-nvim-lsp = { url = github:hrsh7th/cmp-nvim-lsp; flake = false; };
    vimplugin-fterm = { url = github:numtostr/FTerm.nvim; flake = false; };
    vimplugin-gitsigns-nvim = { url = github:lewis6991/gitsigns.nvim; flake = false; };
    vimplugin-lualine = { url = github:hoob3rt/lualine.nvim; flake = false; };
    vimplugin-nvim-cmp = { url = github:hrsh7th/nvim-cmp; flake = false; };
    vimplugin-nvim-colorizer = { url = github:norcalli/nvim-colorizer.lua; flake = false; };
    vimplugin-nvim-hlslens = { url = github:kevinhwang91/nvim-hlslens; flake = false; };
    vimplugin-nvim-lspconfig = { url = github:neovim/nvim-lspconfig; flake = false; };
    vimplugin-nvim-treesitter = { url = github:nvim-treesitter/nvim-treesitter; flake = false; };
    vimplugin-nvim-treesitter-context = { url = github:romgrk/nvim-treesitter-context; flake = false; };
    vimplugin-nvim-ts-rainbow = { url = github:p00f/nvim-ts-rainbow; flake = false; };
    vimplugin-plenary-nvim = { url = github:vkleen/plenary.nvim; flake = false; };
    vimplugin-rust-tools = { url = github:simrat39/rust-tools.nvim; flake = false; };
    vimplugin-telescope-ghq = { url = github:nvim-telescope/telescope-ghq.nvim; flake = false; };
    vimplugin-telescope-lsp-handlers = { url = github:gbrlsnchs/telescope-lsp-handlers.nvim; flake = false; };
    vimplugin-telescope-zoxide = { url = github:jvgrootveld/telescope-zoxide; flake = false; };
    vimplugin-vim-vsnip-integ = { url = github:hrsh7th/vim-vsnip-integ; flake = false; };
    vimplugin-vim-vsnip = { url = github:hrsh7th/vim-vsnip; flake = false; };
    vimplugin-which-key-nvim = { url = github:folke/which-key.nvim; flake = false; };
    vimplugin-neorg = { url = github:nvim-neorg/neorg; flake = false; };
    vimplugin-fzf-vim = { url = github:junegunn/fzf.vim; flake = false; };
    vimplugin-popup-nvim = { url = github:nvim-lua/popup.nvim; flake = false; };
    vimplugin-telescope-nvim = { url = github:nvim-telescope/telescope.nvim; flake = false; };
    vimplugin-telescope-fzf-nvim = { url = github:nvim-telescope/telescope-fzf-native.nvim; flake = false; };
    vimplugin-lightspeed-nvim = { url = github:ggandor/lightspeed.nvim; flake = false; };
    vimplugin-nerdcommenter = { url = github:preservim/nerdcommenter; flake = false; };
    vimplugin-indent-blankline = { url = github:lukas-reineke/indent-blankline.nvim; flake = false; };
    vimplugin-direnv-vim = { url = github:direnv/direnv.vim; flake = false; };
    vimplugin-nvim-notify = { url = github:rcarriga/nvim-notify; flake = false; };
    vimplugin-trouble-nvim = { url = github:folke/trouble.nvim; flake = false; };
    vimplugin-nvim-dap = { url = github:mfussenegger/nvim-dap; flake = false; };
    vimplugin-nvim-dap-ui = { url = github:rcarriga/nvim-dap-ui; flake = false; };
    vimplugin-telescope-dap-nvim = { url = github:nvim-telescope/telescope-dap.nvim; flake = false; };
    vimplugin-crates-nvim = { url = github:saecki/crates.nvim; flake = false; };
    vimplugin-cmp_luasnip = { url = github:saadparwaiz1/cmp_luasnip; flake = false; };
    vimplugin-luasnip = { url = github:l3mon4d3/luasnip; flake = false; };
    vimplugin-lsp-colors-nvim = { url = github:folke/lsp-colors.nvim; flake = false; };
    vimplugin-nvim-web-devicons = { url = github:kyazdani42/nvim-web-devicons; flake = false; };
  };
  outputs = inputs: let 
    inherit (inputs.utils.lib)
      filterAttrs
      forAllSystems
      mapAttrs'
      nameValuePair
      optional
      strings
      ;
    
    addRtp = path: drv:
      drv // { rtp = "${drv}/${path}"; };

    vimPlugin = pkgs: ref: vimPluginSubdir pkgs ref "";
    vimPluginSubdir = pkgs: ref_: d: let
      ref = strings.removePrefix "vimplugin-" ref_;
    in addRtp "${ref}" (pkgs.stdenv.mkDerivation {
      name = "${strings.sanitizeDerivationName ref}";
      forceShare = [ "man" "info" ];
      nativeBuildInputs = optional
        (pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform)
        pkgs.vimUtils.vimGenDocHook;
      unpackPhase = ":";
      buildPhase = ":";
      configurePhase = ":";
      installPhase = ''
        runHook preInstall
        mkdir -p "$out"
        cp -r "${inputs.self.inputs."${ref}".outPath}/${d}/"* "$out"
        runHook postInstall
      '';
    });

    update-grammars = s: let
      pkgs = inputs.nixpkgs.legacyPackages.${s};
      inherit (inputs.neovim-flake.packages.${s}) neovim;
    in pkgs.writers.writePython3 "update-grammars" {
      libraries = [];
      flakeIgnore = [ "E401" "E501" "W503" "E265" ];
    } (pkgs.substituteAll {
      src = ./ts-grammars/updater.py;
      nixPrefetchGit = "${pkgs.nix-prefetch-git}/bin/nix-prefetch-git";
      abiVersion = pkgs.runCommand "neovim-treesitter-abi-version" { nvim = "${neovim}/bin/nvim"; } ''
        $nvim -i NONE -u NONE --headless --cmd 'lua print(vim.treesitter.language_version)' --cmd qa >$out 2>&1
      '';
    });

  in {
    vimPluginsOverrides = pkgs: import ./overrides.nix { inherit addRtp pkgs; };
    vimPlugins = pkgs: _: mapAttrs'
      (n: v: let name = strings.removePrefix "vimplugin-" n; in nameValuePair name (vimPlugin pkgs n))
      (filterAttrs (n: _: strings.hasPrefix "vimplugin-" n) inputs.self.inputs);

    packages = forAllSystems (s: {
      update-grammars = update-grammars s;
    });
    apps = forAllSystems (s: {
      update-grammars = {
        type = "app";
        program = "${inputs.self.packages.${s}.update-grammars}";
      };
    });
    checks = forAllSystems (s:
      inputs.self.packages.${s} //
      (inputs.nixpkgs.legacyPackages.${s}.callPackage ./ts-grammars {}).builtGrammars
    );
  };
}
