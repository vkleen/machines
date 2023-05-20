{ mkNixosConfig, lib, self, ... }:
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
      # boot.supportedFilesystems = [ "zfs" ];
      # boot.zfs = {
      #   enableUnstable = true;
      #   forceImportRoot = false;
      #   forceImportAll = false;
      # };
    }
    {
      systemd.services.nix-daemon.environment.TMPDIR = "/nix/tmp";
    }
    {
      hardware.uinput.enable = true;
    }
    {
      virtualisation.docker = {
        enable = true;
        enableOnBoot = false;
      };
    }
  ] ++ lib.attrValues {
    inherit (self.nixosModules)
      chrony
      doas
      latest-linux
      nix
      nix-monitored
      ssh
      zram
      ;

    inherit (self.nixosModules.accounts)
      root;

    inherit (self.nixosModules.accounts.vkleen)
      core workstation graphical;
  };
}
