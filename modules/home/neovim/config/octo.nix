{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [ octo-nvim nvim-web-devicons ];
    extraConfigLua = /*lua*/ ''
      require("octo").setup()
    '';
  };
}
