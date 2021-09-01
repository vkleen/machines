{ flake, config, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./extra-scripts.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    latest-linux
    no-coredump
    ssh
    zfs
  ]);

  nixpkgs = rec {
    system = "powerpc64le-linux";
  };

  nix = {
    binaryCaches = [
    ];

    binaryCachePublicKeys = [
    ];
    maxJobs = 72;
    buildCores = 72;
    extraOptions = ''
      secret-key-files = /run/keys/chlorine.1.sec
    '';
  };

  networking.hostId = "53199d00";
  environment.etc.machine-id.text = "53199d006f21acb7707e9ed34c1c4a3a";
}
