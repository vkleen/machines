{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.nil ];
  programs.nixvim = {
    extraFiles."ftplugin/nix.lua" = /*lua*/ ''
      vim.bo.expandtab = true
      vim.bo.shiftwidth = 2
      vim.bo.softtabstop = 2
      vim.bo.tabstop = 2
    '';
    plugins.lsp.servers.nil_ls = {
      enable = true;
      settings.formatting.command = ["${lib.getExe pkgs.nixpkgs-fmt}"];
    };
  };
}
