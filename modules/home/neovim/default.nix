{ pkgs, lib, inputs, ... }:

with builtins;
with lib;
let
  lazy-nix-helper-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "lazy-nix-helper.nvim";
    version = "2024-08-29";
    src = pkgs.fetchFromGitHub {
      owner = "b-src";
      repo = "lazy-nix-helper.nvim";
      rev = "cb1c0c4cf0ab3c1a2227dcf24abd3e430a8a9cd8";
      hash = "sha256-HwrO32Sj1FUWfnOZQYQ4yVgf/TQZPw0Nl+df/j0Jhbc=";
    };
  };

  trailblazer-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "trailblazer.nvim";
    version = "2023-04-08";
    src = pkgs.fetchFromGitHub {
      owner = "LeonHeidelbach";
      repo = "trailblazer.nvim";
      rev = "674bb6254a376a234d0d243366224122fc064eab";
      hash = "sha256-9q8CmbUGmbKb7w4fzOS7XBSg8YM5WwqwvLUN2pVOAtI=";
    };
  };

  bufresize-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "bufresize.nvim";
    version = "2022-03-21";
    src = pkgs.fetchFromGitHub {
      owner = "kwkarlwang";
      repo = "bufresize.nvim";
      rev = "3b19527ab936d6910484dcc20fb59bdb12322d8b";
      hash = "sha256-6jqlKe8Ekm+3dvlgFCpJnI0BZzWC3KDYoOb88/itH+g=";
    };
  };

  sanitizePluginName = input:
    let
      name = lib.strings.getName input;
      intermediate = lib.strings.removePrefix "vimplugin-" name;
      result = lib.strings.removePrefix "lua5.1-" intermediate;
    in
    result;

  blink = inputs.blink-cmp.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (o: {
    patches = [
      ./force-blink-version.patch
    ];
  });

  plugins = with pkgs.vimPlugins; [
    blink
    bufresize-nvim
    catppuccin-nvim
    conform-nvim
    diffview-nvim
    fidget-nvim
    fzf-lua
    gitsigns-nvim
    lazydev-nvim
    luvit-meta
    mini-nvim
    neogit
    nvim-lspconfig
    nvim-treesitter
    plenary-nvim
    tiny-inline-diagnostic-nvim
    trailblazer-nvim
    vim-sleuth
    which-key-nvim
    inputs.rustaceanvim.packages.${pkgs.stdenv.hostPlatform.system}.rustaceanvim
    haskell-tools-nvim
  ];

  pluginList = plugins:
    lib.strings.concatMapStrings
      (plugin: "  [\"${sanitizePluginName plugin}\"] = \"${plugin.outPath}\",\n")
      plugins;

  nix-treesitter-grammars =
    let
      grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
      grammarName = grammar:
        lib.pipe grammar [
          lib.getName

          # added in buildGrammar
          (lib.removeSuffix "-grammar")

          # grammars from tree-sitter.builtGrammars
          (lib.removePrefix "tree-sitter-")
          (lib.replaceStrings [ "-" ] [ "_" ])
        ];
    in
    pkgs.linkFarm "nix-treesitter-grammars" (builtins.map
      (p: {
        name = "parser/${grammarName p}.so";
        path = "${p}/parser";
      })
      grammars);
in
{
  home.packages = [ pkgs.neovim-remote ];

  xdg.configFile."nvim/lua" = {
    source = ./lua;
    recursive = true;
  };

  stylix.targets.neovim.enable = false;

  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    extraPackages = with pkgs; [
      delta
      ripgrep
    ];
    plugins = [
      lazy-nix-helper-nvim
      pkgs.vimPlugins.lazy-nvim
    ];

    extraLuaConfig = /* lua */ ''
      local plugins = {
        ${pluginList plugins}
        ["nix-treesitter-grammars"] = "${nix-treesitter-grammars}",
      }
      local lazy_nix_helper_path = "${lazy-nix-helper-nvim}"
      if not vim.loop.fs_stat(lazy_nix_helper_path) then
        lazy_nix_helper_path = vim.fn.stdpath("data") .. "/lazy_nix_helper/lazy_nix_helper.nvim"
        if not vim.loop.fs_stat(lazy_nix_helper_path) then
          vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/b-src/lazy_nix_helper.nvim.git",
            lazy_nix_helper_path,
          })
        end
      end

      vim.opt.rtp:prepend(lazy_nix_helper_path)

      local non_nix_lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      local lazy_nix_helper_opts = { lazypath = non_nix_lazypath, input_plugin_table = plugins }
      require("lazy-nix-helper").setup(lazy_nix_helper_opts)

      local lazypath = require("lazy-nix-helper").lazypath()
      if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable", -- latest stable release
          lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)

      require("vkleen")
    '';
  };
}
