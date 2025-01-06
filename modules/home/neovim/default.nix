{ pkgs, lib, config, inputs, ... }:

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

  sanitizePluginName = input:
    let
      name = lib.strings.getName input;
      intermediate = lib.strings.removePrefix "vimplugin-" name;
      result = lib.strings.removePrefix "lua5.1-" intermediate;
    in
    result;

  plugins = with pkgs.vimPlugins; [
    lazy-nix-helper-nvim
    lazy-nvim
  ];

  pluginList = plugins: lib.strings.concatMapStrings (plugin: "  [\"${sanitizePluginName plugin}\"] = \"${plugin.outPath}\",\n") plugins;
in
{
  # imports = [
  #   inputs.nixvim.homeManagerModules.nixvim
  # ] ++ (findModulesList ./config);

  home.packages = [ pkgs.neovim-remote ];

  # programs.nixvim = {
  #   enable = false;
  #   luaLoader.enable = true;
  #   viAlias = true;
  #   vimAlias = true;
  #   extraPackages = [ pkgs.delta ];
  #   enableMan = false;
  # };

  xdg.configFile."nvim/lua" = {
    source = ./lua;
    recursive = true;
  };

  catppuccin.nvim.enable = false;

  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    extraPackages = with pkgs; [
      delta
      ripgrep
    ];
    inherit plugins;

    extraLuaConfig = ''
      local plugins = {
        ${pluginList plugins}
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
