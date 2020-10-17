flake:
{ modulesPath, pkgSources, pkgset, ... }: {
  imports = [
    ../users/root ../users/vkleen
    ./chlorine/hardware.nix
    ./chlorine/networking.nix
    ./chlorine/extra-scripts.nix
  ] ++ (with flake.nixosModules.profiles; [
    latest-linux
    no-coredump
    ssh
    zfs
  ]);

  nixpkgs = rec {
    system = "powerpc64le-linux";
    pkgs = pkgset."${system}";
  };

  nix = {
    nixPath = [
      "nixpkgs=${pkgSources.local-power9}"
    ];
    registry = {
      nixpkgs.flake = pkgSources.local-power9;
    };
    binaryCaches = [
      "s3://vkleen-nix-cache?region=eu-central-1"
    ];

    binaryCachePublicKeys = [
      "seaborgium.1:0cDg6+fSZ4Z4L7T24SPPal5VN4m51P5o2NDfUycbKmo="
      (builtins.readFile ../secrets/aws/aws-vkleen-nix-cache-1.public)
    ];
    maxJobs = 72;
    buildCores = 72;
    extraOptions = ''
      secret-key-files = /run/keys/chlorine.1.sec
      builders-use-substitutes = true
      keep-outputs = true
    '';
  };

  networking.hostId = "53199d00";
  environment.etc.machine-id.text = "53199d006f21acb7707e9ed34c1c4a3a";
}
