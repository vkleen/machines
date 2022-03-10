{ pkgs, lib, config, ... }:
{
  config = lib.mkMerge ([
    {
      security.rtkit.enable = true;
      hardware.bluetooth = {
        enable = true;
        package = pkgs.bluezFull;
      };
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    }
    (lib.mkIf config.boot.wipeRoot {
      systemd.tmpfiles.rules = [
        "L /var/lib/bluetooth - - - - /persist/bluetooth"
      ];
    })
  ]);
}
