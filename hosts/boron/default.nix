{ flake, config, hostName, modulesPath, pkgSources, pkgset, ... }: {
  imports = [
    ./backup.nix
    ./hardware.nix
    ./networking.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    initrd-all-crypto-modules
    latest-linux
    mosquitto
    no-coredump
    rmfakecloud
    ssh
    zfs
  ]);

  nixpkgs = rec {
    system = "aarch64-linux";
  };

  nix = {
    binaryCaches = [
    ];

    binaryCachePublicKeys = [
    ];
    maxJobs = 4;
    buildCores = 4;
    extraOptions = ''
      secret-key-files = /persist/private/boron.1.sec
    '';
  };

  networking.hostId = "cc6b36a1";
  environment.etc."machine-id".text = "cc6b36a180ac98069c5e6266bf0b4041";
}
