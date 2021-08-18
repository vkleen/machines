{ flake, config, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    airplay-server
    binfmt
    desktop
    docker
    flatpak
    interception-tools
    laptop
    latest-linux
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
      (builtins.readFile ../../secrets/aws/aws-vkleen-nix-cache-1.public)
    ];
    maxJobs = 4;
    buildCores = 4;
    extraOptions = ''
      secret-key-files = /persist/private/bohrium.1.sec
      builders-use-substitutes = true
      keep-outputs = true
    '';
  };

  networking.hostId = "2469eead";
  environment.etc."machine-id".text = "2469eead8c84bfe7caf902d7f00a1a7c";

  services.lock-on-suspend.enable = true;
}
