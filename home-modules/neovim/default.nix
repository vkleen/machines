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
          lua <<EOF
          ${lib.strings.fileContents ./config.lua}
          ${lib.strings.fileContents ./bindings.lua}
          ${lib.strings.fileContents ./plugins.lua}
          ${lib.strings.fileContents ./lsp.lua}
          EOF
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
        telescope-frecency-nvim
        telescope-fzf-native-nvim
        telescope-zoxide
        telescope-lsp-handlers

        lightspeed-nvim
        limelight-vim
        goyo-vim

        nerdcommenter

        direnv-vim

        nvim-notify

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
      ];
    };
  };
}
