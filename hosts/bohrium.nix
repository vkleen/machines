flake:
{ modulesPath, pkgSources, pkgset, ... }: {
  imports = [
    ../users/root ../users/vkleen
    ./bohrium/cups.nix
    ./bohrium/dconf.nix
    ./bohrium/hardware.nix
    ./bohrium/networking.nix
    ./bohrium/persist.nix
    ./bohrium/power.nix
    ./bohrium/udev.nix
    ./bohrium/zfs.nix
  ] ++ (with flake.nixosModules.profiles; [
    desktop
    latest-linux
    no-coredump
    ssh
    uucp-email
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
      (import ../secrets/aws/aws-vkleen-nix-cache-1.public)
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
