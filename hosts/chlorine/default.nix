{ flake, config, lib, pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./extra-scripts.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    initrd-all-crypto-modules
    latest-linux
    no-coredump
    ssh
    zfs
  ]);

  nixpkgs = rec {
    system = "powerpc64le-linux";
  };

  nix.settings = {
    max-jobs = 144;
    cores = 72;
  };

  networking.hostId = "53199d00";
  environment.etc.machine-id.text = "53199d006f21acb7707e9ed34c1c4a3a";
}
