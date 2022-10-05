{ pkgs, lib, config, ... }:
{
  config = lib.mkMerge ([
    {
      security.rtkit.enable = true;
      hardware.bluetooth = {
        enable = true;
        package = pkgs.bluez;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
          };
        };
      };

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        media-session.enable = false;
        wireplumber.enable = true;
        config.pipewire = {
          "context.properties" = {
            "link.max-buffers" = 16;
            "log.level" = 2;
            "default.clock.rate" = 192000;
            "default.clock.quantum" = 2048;
            "default.clock.min-quantum" = 32;
            "default.clock.max-quantum" = 4096;
            "core.daemon" = true;
            "core.name" = "pipewire-0";
          };
          "context.modules" = [
            {
              name = "libpipewire-module-rtkit";
              args = {
                "nice.level" = -15;
                "rt.prio" = 88;
                "rt.time.soft" = 200000;
                "rt.time.hard" = 200000;
              };
              flags = [ "ifexists" "nofail" ];
            }
            { name = "libpipewire-module-protocol-native"; }
            { name = "libpipewire-module-profiler"; }
            { name = "libpipewire-module-metadata"; }
            { name = "libpipewire-module-spa-device-factory"; }
            { name = "libpipewire-module-spa-node-factory"; }
            { name = "libpipewire-module-client-node"; }
            { name = "libpipewire-module-client-device"; }
            {
              name = "libpipewire-module-portal";
              flags = [ "ifexists" "nofail" ];
            }
            {
              name = "libpipewire-module-access";
              args = {};
            }
            { name = "libpipewire-module-adapter"; }
            { name = "libpipewire-module-link-factory"; }
            { name = "libpipewire-module-session-manager"; }
          ];
        };
        config.pipewire-pulse = {
          "context.properties" = {
            "log.level" = 2;
          };
          "context.modules" = [
            {
              name = "libpipewire-module-rtkit";
              args = {
                "nice.level" = -15;
                "rt.prio" = 88;
                "rt.time.soft" = 200000;
                "rt.time.hard" = 200000;
              };
              flags = [ "ifexists" "nofail" ];
            }
            { name = "libpipewire-module-protocol-native"; }
            { name = "libpipewire-module-client-node"; }
            { name = "libpipewire-module-adapter"; }
            { name = "libpipewire-module-metadata"; }
            {
              name = "libpipewire-module-protocol-pulse";
              args = {
                "pulse.min.req" = "32/192000";
                "pulse.default.req" = "2048/192000";
                "pulse.max.req" = "4096/192000";
                "pulse.min.quantum" = "32/192000";
                "pulse.max.quantum" = "4096/192000";
                "server.address" = [ "unix:native" ];
              };
            }
          ];
          "stream.properties" = {
            "node.latency" = "4096/192000";
            "resample.quality" = 1;
          };
        };
      };
    }
    (lib.mkIf config.boot.wipeRoot {
      fileSystems."/var/lib/bluetooth" = {
        device = "/persist/bluetooth";
        options = [ "bind" ];
      };
    })
  ]);
}
