{ flake, config, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    latest-linux
    matrix-go-neb
    matrix-server
    no-coredump
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
    extraOptions = ''
      secret-key-files = /run/secrets/europium.1.sec
    '';
  };

  age.secrets."europium.1.sec".file = ../../secrets/nix/europium.1.sec.age;

  networking.hostId = "f8a1f27f";
  environment.etc."machine-id".text = "f8a1f27fe211912366eb4b536c533419";

  services.rmfakecloud-proxy = let
    boronPublicAddress = (builtins.elemAt flake.nixosConfigurations.boron.config.networking.interfaces."auenheim".ipv6.addresses 0).address;
  in {
    enable = true;
    endpoint = "[${boronPublicAddress}]:3000";
  };
}
