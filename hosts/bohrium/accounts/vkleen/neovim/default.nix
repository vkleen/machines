{ lib, pkgs, ... }:
with lib;
with builtins;
{
  # imports = attrValues (findModules ./.);
  programs.neovide = {
    enable = true;
    settings = {
      fork = true;
      font = {
        normal = [ "PragmataPro Mono" "Noto Color Emoji" ];
        size = 12;
      };
    };
  };
}
