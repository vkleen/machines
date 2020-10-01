{ pkgs, lib, config, ... }:
{
  config = lib.mkMerge ([
    {
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
      hardware.pulseaudio = {
        enable = true;
        extraModules = [ pkgs.pulseaudio-modules-bt ];
        package = pkgs.pulseaudioFull;
        extraConfig = ''
          load-module module-switch-on-connect
        '';
      };
    }
    (lib.mkIf config.boot.wipeRoot {
      systemd.tmpfiles.rules = [
        "L /var/lib/bluetooth - - - - /persist/bluetooth"
      ];
    })
  ]);
}
