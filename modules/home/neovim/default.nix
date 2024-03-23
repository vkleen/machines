{ pkgs, lib, inputs, ... }:

with builtins;
with lib;
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ] ++ (findModulesList ./config);

  home.packages = [ pkgs.neovim-remote ];

  programs.nixvim = {
    enable = true;
    luaLoader.enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = [ pkgs.delta ];
    enableMan = false;
  };
}
