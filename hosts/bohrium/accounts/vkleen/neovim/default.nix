{ lib, ... }:
with lib;
with builtins;
{
  imports = attrValues (findModules ./.);
}
