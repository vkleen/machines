{ mkNixosConfig, lib, inputs, ... }:
mkNixosConfig {
  hostName = "chlorine";
  hostPlatform = "powerpc64le-linux";
  modules = [
    {
      system.macnameNamespace = "auenheim.kleen.org";
      system.stateVersion = "23.05";
    }
    ./hardware.nix
    ./networking.nix
    {
      nix.settings = {
        max-jobs = 144;
        cores = 144;
      };
    }
    {
      boot.supportedFilesystems = [ "zfs" ];
      boot.zfs = {
        enableUnstable = true;
        forceImportRoot = false;
        forceImportAll = false;
      };
    }
    {
      systemd.services.nix-daemon.environment.TMPDIR = "/nix/tmp";
    }
  ] ++ lib.attrValues {
    inherit (inputs.self.nixosModules)
      chrony
      doas
      latest-linux
      nix
      nix-monitored
      ssh
      zram
      ;

    inherit (inputs.self.nixosModules.accounts)
      root;

    inherit (inputs.self.nixosModules.accounts.vkleen)
      core workstation;
  };
}
