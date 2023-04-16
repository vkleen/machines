{ inputs, system, pkgs, ... }:
{
  imports = [
    inputs.nix-monitored.nixosModules.${system.hostPlatform}.default
  ];

  nix.package = pkgs.nix-monitored;

  nixpkgs.overlays = [
    (final: prev: {
      nix-monitored = inputs.nix-monitored.packages.${system.hostPlatform}.default.override (final // { withNotify = false; });
      nix-direnv = prev.nix-direnv.override {
        nix = final.nix-monitored;
      };
    })
  ];
}
