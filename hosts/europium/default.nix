{ flake, config, hostName, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./ejabberd.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    hostid
    latest-linux
    matrix-go-neb
    matrix-server
    no-coredump
    ntp-server
    ssh
  ]);

  nixpkgs = {
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
    boronWgAddress = "2a01:7e01:e002:aa00:cc6b:36a1:0:1";
    boronPublicAddress = (builtins.elemAt flake.nixosConfigurations.boron.config.networking.interfaces."auenheim".ipv6.addresses 0).address;
  in {
    enable = true;
    endpoint = "[${boronWgAddress}]:3000";
  };
}
