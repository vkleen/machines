{ pkgs, config, lib, ... }:
{
  home.sessionVariables.EDITOR = "${lib.getExe config.programs.neovim.finalPackage}";
}
