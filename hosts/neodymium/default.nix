{ flake, config, hostName, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./mailserver.nix
    ./math.kleen.org.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    hostid
    latest-linux
#    matrix-go-neb
#    matrix-server
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
  };

  system.macnameNamespace = "wolkenheim.kleen.org";

  services.rmfakecloud-proxy = let
    boronWgAddress = "10.172.50.136";
  in {
    enable = true;
    endpoint = "${boronWgAddress}:3000";
  };

  services.grafana-proxy = let
    boronWgAddress = "10.172.50.136";
  in {
    enable = true;
    endpoint = "${boronWgAddress}:2342";
  };

  services.sourcehut-proxy = let
    boronWgAddress = "10.172.50.136";
  in {
    enable = true;
    endpoints = {
      git = "${boronWgAddress}:8081";
      meta = "${boronWgAddress}:8082";
      paste = "${boronWgAddress}:8083";
    };
  };

  services.paperless-proxy = let
    boronWgAddress = "10.172.50.136";
  in {
    enable = true;
    endpoint = "${boronWgAddress}:58080";
  };
}
