{ flake, modulesPath, pkgSources, pkgset, config, ... }: {
  imports = [
    ../users/root ../users/vkleen
    ./bohrium/hardware.nix
    ./bohrium/networking.nix
  ] ++ (with flake.nixosModules.profiles; [
    airplay-server
    desktop
    # jack
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
    pkgs = pkgset."${system}";
  };

  nix = {
    nixPath = [
      "nixpkgs=${pkgSources.local}"
      "nixpkgs-overlays=${flake.overlays-path."${config.nixpkgs.system}"}"
    ];
    registry = {
      nixpkgs.flake = pkgSources.local;
    };
    binaryCaches = [
      "s3://vkleen-nix-cache?region=eu-central-1"
    ];

    binaryCachePublicKeys = [
      "seaborgium.1:0cDg6+fSZ4Z4L7T24SPPal5VN4m51P5o2NDfUycbKmo="
      (builtins.readFile ../secrets/aws/aws-vkleen-nix-cache-1.public)
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
}
