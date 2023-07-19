{ inputs, system, pkgs, ... }:
{
  imports = [
    inputs.nix-monitored.nixosModules.default
  ];

  nix.monitored = {
    enable = true;
    notify = false;
  };
}
