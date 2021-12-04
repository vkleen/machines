{ flake, config, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./mailserver.nix
    ./math.kleen.org.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    latest-linux
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
      secret-key-files = /run/agenix/samarium.2.sec
    '';
  };

  age.secrets."samarium.2.sec".file = ../../secrets/nix/samarium.2.sec.age;

  networking.hostId = "c4decb69";
  environment.etc."machine-id".text = "c4decb69165ba83fa1167e065c1a5bc7";
}
