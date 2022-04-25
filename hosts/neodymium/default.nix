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

  services.certspotter = {
    watchList = [
      ".kleen.org"
      ".17220103.de"
      ".bouncy.email"
      ".as210286.net"
      ".141.li"
      ".dirty-haskell.org"
      ".element.synapse.li"
      ".kleen.li"
      ".nights.email"
      ".praseodym.org"
      ".rheperire.org"
      ".synapse.li"
      ".turn.synapse.li"
      ".webdav.141.li"
      ".xmpp.li"
      ".yggdrasil.li"
    ];
    logs = "https://www.gstatic.com/ct/log_list/v2/all_logs_list.json";
    extraOptions = [ "-verbose" "-num_workers" "4" ];
  };


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
}
