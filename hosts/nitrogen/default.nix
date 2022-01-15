{ flake, config, hostName, modulesPath, pkgSources, pkgset, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    hostid
    initrd-all-crypto-modules
    latest-linux
    no-coredump
    ssh
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
    '';
  };

  system.macnameNamespace = "auenheim.kleen.org";
}
