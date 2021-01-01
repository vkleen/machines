{ flake, config, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    airplay-server
    binfmt
    desktop
    flatpak
    interception-tools
    laptop
    latest-linux
    librem5-devtools
    no-coredump
    ssh
    uucp-email
    virtual-camera
    wireshark
    zfs
  ]);

  nixpkgs = rec {
    system = "x86_64-linux";
  };

  nix = {
    binaryCaches = [
      "s3://vkleen-nix-cache?region=eu-central-1"
    ];

    binaryCachePublicKeys = [
    ];
    maxJobs = 4;
    buildCores = 4;
  };

  networking.hostId = "2469eead";
  environment.etc."machine-id".text = "2469eead8c84bfe7caf902d7f00a1a7c";
}
