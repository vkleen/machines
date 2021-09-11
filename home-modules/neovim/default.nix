{pkgs, config, lib, flake, nixos, ...}:
let
  neovide-wrapped = pkgs.writeShellScriptBin "neovide" ''
    exec ${pkgs.neovide}/bin/neovide "$@"
  '';
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
        (lib.strings.fileContents ./base.vim)
        (lib.strings.fileContents ./plugins.vim)

        ''
          lua <<EOF
          ${lib.strings.fileContents ./config.lua}
          ${lib.strings.fileContents ./lsp.lua}
          ${lib.strings.fileContents ./haskell.lua}
          EOF
        ''
      ];

      plugins = with pkgs.vimPlugins; [
        vim-which-key
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
        telescope-frecency-nvim
        telescope-fzf-native-nvim
        telescope-z-nvim

        lightspeed-nvim
        limelight-vim
        goyo-vim

        nerdcommenter
      ] ++ (with flake.vimPlugins.${nixos.nixpkgs.system}; [
        nvim-lspconfig
        nvim-ts-rainbow
        nvim-treesitter-context

        rust-tools

        clever-f

        nvim-cmp
        vim-vsnip
        vim-vsnip-integ
        cmp-buffer
        cmp-nvim-lsp

        nvim-colorizer
        gitsigns

        bufferline
        lualine

        fterm

        telescope-ghq

        nvim-selenized
      ]);
    };
  };
}
