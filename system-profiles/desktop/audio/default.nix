{ pkgs, lib, config, ... }:
{
  config = lib.mkMerge ([
    {
      security.rtkit.enable = true;
      hardware.bluetooth = {
        enable = true;
        package = pkgs.bluezFull;
      };
      services.blueman.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;

        media-session = {
          enable = true;
          config.bluez-monitor.rules = [
            { # Matches all cards
              matches = [ { "device.name" = "~bluez_card.*"; } ];
              actions = {
                "update-props" = {
                  "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
                  # mSBC is not expected to work on all headset + adapter combinations.
                  "bluez5.msbc-support" = true;
                };
              };
            }
            {
              matches = [
                # Matches all sources
                { "node.name" = "~bluez_input.*"; }
                # Matches all outputs
                { "node.name" = "~bluez_output.*"; }
              ];
              actions = {
                "update-props" = {
                  "node.pause-on-idle" = false;
                };
              };
            }
          ];
        };
      };
    }
    (lib.mkIf config.boot.wipeRoot {
      systemd.tmpfiles.rules = [
        "L /var/lib/bluetooth - - - - /persist/bluetooth"
      ];
    })
  ]);
}
