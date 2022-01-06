{ flake, config, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    hostid
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

  system.macnameNamespace = "wolkenheim.kleen.org";
}
