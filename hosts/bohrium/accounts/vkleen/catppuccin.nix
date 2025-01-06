{ inputs, ... }:
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];
  config = {
    catppuccin.enable = true;
    catppuccin.flavor = "mocha";
  };
}
