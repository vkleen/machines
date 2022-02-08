{ flake, config, hostName, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./mailserver.nix
    ./math.kleen.org.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    hostid
    latest-linux
    no-coredump
    ssh
  ]);

  nixpkgs = rec {
    system = "x86_64-linux";
  };

  nix.settings = {
    max-jobs = 4;
    cores = 1;
    secret-key-files = "/run/agenix/samarium.2.sec";
  };

  age.secrets."samarium.2.sec".file = ../../secrets/nix/samarium.2.sec.age;

  system.macnameNamespace = "wolkenheim.kleen.org";
}
