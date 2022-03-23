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
    boronWgAddress = "10.172.40.136";
  in {
    enable = true;
    endpoint = "${boronWgAddress}:3000";
  };

  services.grafana-proxy = let
    boronWgAddress = "10.172.40.136";
  in {
    enable = true;
    endpoint = "${boronWgAddress}:2342";
  };

  services.sourcehut-proxy = let
    boronWgAddress = "10.172.40.136";
  in {
    enable = true;
    endpoints = {
      git = "${boronWgAddress}:8081";
      meta = "${boronWgAddress}:8082";
      paste = "${boronWgAddress}:8083";
    };
  };
}
