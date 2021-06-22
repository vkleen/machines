{ flake, config, modulesPath, pkgSources, pkgset, ... }: {
  imports = [
    ../users/root
#    ../users/vkleen
    ./tellurium/hardware.nix
    ./tellurium/networking.nix
  ] ++ (with flake.nixosModules.profiles; [
    latest-linux
    no-coredump
    ssh
    zfs
  ]);

  nixpkgs = rec {
    system = "riscv64-linux";
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

  networking.hostId = "b32ce171";
  environment.etc."machine-id".text = "b32ce171b2754bcfab1933e7bdad1394";

  system.configuration-type = "server";
}
