{ flake, config, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
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

  networking.hostId = "0a4beded";
  environment.etc."machine-id".text = "0a4bededda5af4aed0c59432a74eb4c7";

  services.rmfakecloud-proxy = let
    boronPublicAddress = (builtins.elemAt flake.nixosConfigurations.boron.config.networking.interfaces."auenheim".ipv6.addresses 0).address;
  in {
    enable = true;
    endpoint = "[${boronPublicAddress}]:3000";
  };
}
