{ flake, config, hostName, modulesPath, pkgSources, pkgset, ... }: {
  imports = [
    ./backup.nix
    ./hardware.nix
    ./networking.nix
    ./matrix-bifrost.nix
    ./heisenbridge.nix
    ./prometheus
  ] ++ (with flake.nixosModules.systemProfiles; [
    initrd-all-crypto-modules
    latest-linux
    mosquitto
    no-coredump
    rmfakecloud
    ssh
    wolkenheim
    zfs
  ]);

  nixpkgs = rec {
    system = "aarch64-linux";
  };

  nix.settings = {
    max-jobs = 4;
    cores = 4;
    secret-key-files = "/persist/private/boron.1.sec";
  };

  networking.hostId = "cc6b36a1";
  environment.etc."machine-id".text = "cc6b36a180ac98069c5e6266bf0b4041";
}
