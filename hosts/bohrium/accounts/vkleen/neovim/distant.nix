{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.distant-nvim ];
    extraConfigLua = /*lua*/''
      require('distant'):setup()
    '';
  };
}
