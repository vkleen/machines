{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.haskell-tools-nvim ];
    plugins.lsp.servers = {
      clangd.enable = true;
      beancount.enable = true;
      gopls.enable = true;
      pyright.enable = true;
      terraformls.enable = true;
    };
  };
}
