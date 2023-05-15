{ system, inputs, lib, ... }:
{
  nix = {
    settings = {
      auto-optimise-store = true;
      preallocate-contents = false;
      experimental-features = [ "nix-command" "flakes" "ca-derivations" "auto-allocate-uids" ];
      trusted-users = [ "root" "@wheel" ];
      flake-registry = "";
      auto-allocate-uids = true;
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
