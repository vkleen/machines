flake:
{ modulesPath, pkgSources, pkgset, ... }: {
  imports = [
    ../users/root ../users/vkleen
    ./linode-hardware.nix
    ./europium/networking.nix
  ] ++ (with flake.nixosModules.profiles; [
    latest-linux
    matrix-go-neb
    no-coredump
    ssh
  ]);

  nixpkgs = rec {
    system = "x86_64-linux";
    pkgs = pkgset."${system}";
  };

  nix = {
    nixPath = [
      "nixpkgs=${pkgSources.local}"
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
      secret-key-files = /persist/private/europium.1.sec
      builders-use-substitutes = true
      keep-outputs = true
    '';
  };

  networking.hostId = "f8a1f27f";
  environment.etc."machine-id".text = "f8a1f27fe211912366eb4b536c533419";
}
