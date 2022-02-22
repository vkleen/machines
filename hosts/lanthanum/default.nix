{ flake, config, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./cluster.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    hostid
    latest-linux
    no-coredump
    ntp-server
    ssh
    wolkenheim
  ]);

  nixpkgs = rec {
    system = "x86_64-linux";
  };

  nix.settings = {
    max-jobs = 4;
    cores = 1;
  };

  system.macnameNamespace = "wolkenheim.kleen.org";
}
