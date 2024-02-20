{ inputs, lib, ... }:

{
  imports = [
    inputs.nix-monitored.nixosModules.default
  ];

  nix = {
    channel.enable = false;
    monitored = {
      enable = true;
      notify = false;
    };
    settings = {
      auto-optimise-store = true;
      preallocate-contents = false;
      auto-allocate-uids = true;
      experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" ];
      trusted-users = [ "root" "@wheel" "@admin" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
      dates = "monthly";
    };
    registry = lib.mkForce { };
    nixPath = lib.mkForce [ ];
  };
}
