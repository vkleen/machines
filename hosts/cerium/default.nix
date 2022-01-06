{ flake, config, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    latest-linux
    no-coredump
    ntp-server
    ssh
  ]);

  nixpkgs = rec {
    system = "x86_64-linux";
  };

  nix = {
    binaryCaches = [
    ];

    binaryCachePublicKeys = [
    ];
    maxJobs = 4;
    buildCores = 4;
  };

  networking.hostId = "443f7eb1";
  environment.etc."machine-id".text = "443f7eb1323b87d9d2bf7c240e57bb7c";
}
