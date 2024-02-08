{ lib, inputs, ... }:

with builtins;
with lib;
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ] ++ attrValues (findModules ./config);

  programs.nixvim = {
    enable = true;
    luaLoader.enable = true;
  };
}
