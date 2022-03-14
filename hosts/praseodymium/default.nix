{ flake, config, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    hostid
    latest-linux
    no-coredump
    ntp-server
    ssh
  ]);

  nixpkgs = rec {
    system = "x86_64-linux";
  };

  nix = {
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedClass = "idle";

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    settings = {
      max-jobs = 4;
      cores = 1;
    };
  };

  system.macnameNamespace = "wolkenheim.kleen.org";
}
