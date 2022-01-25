{pkgs, config, lib, flake, nixos, ...}:
let
  neovide-wrapped = pkgs.writeShellScriptBin "neovide" ''
    exec ${pkgs.neovide}/bin/neovide --multigrid "$@"
  '';

  flakePlugins = flake.vimPlugins.${nixos.nixpkgs.system};
  vimPlugins = pkgs.vimPlugins.extend (vfinal: vprev: flakePlugins);
in {
  options = {
    neovim.package = lib.mkOption {
      default = pkgs.neovim-nightly;
      type = lib.types.package;
    };
  };
  config = {
    home.sessionVariables = {
      EDITOR = "${config.programs.neovim.finalPackage}/bin/nvim";
    };

    home.packages = [
      neovide-wrapped
      pkgs.neovim-remote
      pkgs.rnix-lsp pkgs.nixpkgs-fmt
    ];
    programs.neovim = {
      enable = true;
      viAlias = true;
      withPython3 = true;

      extraPackages = with pkgs; [
        tree-sitter
        jq curl
        gopls texlab rust-analyzer
      ];

      extraConfig = builtins.concatStringsSep "\n" [
        ''
          lua dofile("${./config.lua}")
          lua dofile("${./colors.lua}").setup{}
          lua dofile("${./bindings.lua}")
          lua dofile("${./plugins.lua}")
          lua dofile("${./lsp.lua}")
        ''
      ];

      plugins = with vimPlugins; [
        which-key-nvim
        fzf-vim

        (nvim-treesitter.withPlugins (p: with p; [
          tree-sitter-agda
          tree-sitter-bash
          tree-sitter-c
          tree-sitter-comment
          tree-sitter-cpp
          tree-sitter-go
          tree-sitter-haskell
          tree-sitter-javascript
          tree-sitter-json
          tree-sitter-latex
          tree-sitter-lua
          tree-sitter-nix
          tree-sitter-python
          tree-sitter-regex
          tree-sitter-rust
          tree-sitter-verilog
          tree-sitter-yaml
        ]))

        plenary-nvim
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-zoxide
        telescope-lsp-handlers

        lightspeed-nvim

        nerdcommenter

        indent-blankline-nvim

        direnv-vim

        nvim-notify

        trouble-nvim
        nvim-lspconfig
        nvim-ts-rainbow
        nvim-treesitter-context

        nvim-dap
        nvim-dap-ui
        telescope-dap-nvim

        rust-tools
        crates-nvim

        clever-f

        nvim-cmp
        cmp-buffer
        cmp-nvim-lsp
        cmp_luasnip
        luasnip

        nvim-colorizer
        gitsigns

        bufferline
        lualine

        fterm

        telescope-ghq

        lsp-colors-nvim
        nvim-web-devicons
      ];
    };
  };
}
