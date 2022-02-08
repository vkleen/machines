{ flake, config, hostName, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
  ] ++ (with flake.nixosModules.systemProfiles; [
    airplay-server
    desktop
    docker
    flatpak
    hostid
    initrd-all-crypto-modules
    interception-tools
    laptop
    latest-linux
    librem5-devtools
    no-coredump
    ssh
    uucp-email
    virtual-camera
    wireshark
    zfs
  ]);

  nixpkgs = rec {
    system = "x86_64-linux";
  };

  nix.settings = {
      max-jobs = 4;
      cores = 4;
      secret-key-files = "/persist/private/bohrium.1.sec";
      builders-use-substitutes = true;
      keep-outputs = true;
  };

  system.macnameNamespace = "auenheim.kleen.org";

  services.lock-on-suspend.enable = true;
}
