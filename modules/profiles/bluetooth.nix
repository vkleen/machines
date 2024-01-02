{ pkgs, lib, config, ... }:
{
  config = lib.mkMerge [
    {
      hardware.bluetooth = {
        enable = true;
        settings = {
          General = {
            Experimental = "true";
            KernelExperimental = "true";
          };
        };
        input = {
          General = {
            ClassicBondedOnly = true;
          };
        };
      };
      services.blueman.enable = true;
    }
    (lib.mkIf config.boot.wipeRoot {
      environment.persistence."/persist".directories = [
        "/var/lib/bluetooth"
      ];
    })
  ];
}
