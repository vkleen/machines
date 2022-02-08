{ flake, config, hostName, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    hostid
    latest-linux
    matrix-go-neb
    matrix-server
    no-coredump
    ntp-server
    ssh
  ]);

  nixpkgs = rec {
    system = "x86_64-linux";
  };

  nix.settings = {
    max-jobs = 4;
    cores = 1;
    secret-key-files = "/run/agenix/europium.1.sec";
  };

  age.secrets."europium.1.sec".file = ../../secrets/nix/europium.1.sec.age;

  system.macnameNamespace = "wolkenheim.kleen.org";

  services.rmfakecloud-proxy = let
    boronPublicAddress = (builtins.elemAt flake.nixosConfigurations.boron.config.networking.interfaces."auenheim".ipv6.addresses 0).address;
  in {
    enable = true;
    endpoint = "[${boronPublicAddress}]:3000";
  };
}
