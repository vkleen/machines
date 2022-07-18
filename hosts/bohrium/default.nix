{ flake, config, hostName, ... }: {
  imports = [
    ./graphical.nix
    ./hardware.nix
    ./libvirt.nix
    ./networking.nix
    ./power.nix
    ./printer.nix
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

  nix = {
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedClass = "idle";

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    settings = {
      max-jobs = 4;
      cores = 4;
      secret-key-files = "/persist/private/bohrium.1.sec";
      builders-use-substitutes = true;
      keep-outputs = true;
    };
  };

  system.macnameNamespace = "auenheim.kleen.org";

  services.lock-on-suspend.enable = true;
}
