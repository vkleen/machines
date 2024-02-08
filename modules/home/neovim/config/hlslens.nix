{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.nvim-hlslens ];
    extraConfigLua = /*lua*/ ''
      require("hlslens").setup()
    '';
  };
}
