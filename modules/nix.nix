{ system, inputs, lib, ... }:
{
  nix = {
    settings = {
      auto-optimise-store = true;
      preallocate-contents = false;
      experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
      trusted-users = [ "root" "@wheel" ];
      flake-registry = "";
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
      dates = "monthly";
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = lib.mkForce [
      "nixpkgs=${inputs.nixpkgs}"
    ];
  };
}