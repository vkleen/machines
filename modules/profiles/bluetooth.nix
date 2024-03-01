{ pkgs, lib, config, ... }:
{
  config = lib.mkMerge [
    {
      environment.systemPackages = [ pkgs.bluetuith ];
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
    }
    (lib.mkIf config.boot.wipeRoot.enable {
      environment.persistence."/persist".directories = [
        "/var/lib/bluetooth"
      ];
    })
  ];
}
