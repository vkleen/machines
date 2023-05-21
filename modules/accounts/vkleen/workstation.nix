{ lib, inputs, pkgs, ... }:
{
  users.users.vkleen.shell = "${pkgs.zsh}/bin/zsh";
  home-manager.users.vkleen = lib.mkMerge (lib.attrValues {
    inherit (inputs.self.nixosModules.home)
      direnv
      helix
      std-packages
      zsh
      ;
  });
}
