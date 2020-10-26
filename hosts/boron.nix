flake:
{ modulesPath, pkgSources, pkgset, ... }: {
  imports = [
    ../users/root ../users/vkleen
    ./boron/hardware.nix
    ./boron/networking.nix
  ] ++ (with flake.nixosModules.profiles; [
    latest-linux
    no-coredump
    ssh
    zfs
  ]);

  nixpkgs = rec {
    system = "aarch64-linux";
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
      secret-key-files = /persist/private/boron.1.sec
      builders-use-substitutes = true
      keep-outputs = true
    '';
  };

  networking.hostId = "cc6b36a1";
  environment.etc."machine-id".text = "cc6b36a180ac98069c5e6266bf0b4041";
}
