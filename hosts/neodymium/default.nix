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
}
