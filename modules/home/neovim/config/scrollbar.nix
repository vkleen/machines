{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.nvim-scrollbar ];
    extraConfigLua = /*lua*/ ''
      require("scrollbar").setup()
      require("scrollbar.handlers.search").setup()
    '';
  };
}
