{ flake, config, hostName, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    airplay-server
    binfmt
    desktop
    docker
    flatpak
    initrd-all-crypto-modules
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
    ];

    binaryCachePublicKeys = [
    ];
    maxJobs = 4;
    buildCores = 4;
    extraOptions = ''
      secret-key-files = /persist/private/bohrium.1.sec
      builders-use-substitutes = true
      keep-outputs = true
    '';
  };

  networking.hostName = hostName;
  networking.hostId = "2469eead";
  environment.etc."machine-id".text = "2469eead8c84bfe7caf902d7f00a1a7c";

  services.lock-on-suspend.enable = true;
}
