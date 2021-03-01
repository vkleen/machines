{ flake, config, lib, pkgs, ... }:
{
  imports = [
    flake.nixosModules.mosquitto
    ../../secrets/mosquitto.nix
  ];
  services.mosquitto = lib.mkMerge [
    {
      enable = true;
      listeners = [
        { host = "localhost";
          port = 1883;
        }
        { host = "0.0.0.0";
          port = 8883;
          ssl = {
            enable = true;
            cafile = "/persist/mosquitto/ca.pem";
            certfile = "/persist/mosquitto/mqtt.pem";
            keyfile = "/persist/mosquitto/mqtt.key";
          };
        }
      ];
      users = {
        "relayd" = {
          acl = [
            "topic readwrite relays/+/status"
            "topic readwrite relays/+/+/diagnostic"
            "topic read relays/+/+/state"
          ];
        };
        "root" = {
          acl = [
            "topic readwrite #"
            "topic readwrite $SYS/#"
          ];
        };
      };
      allowAnonymous = false;
      checkPasswords = true;
      extraConf = ''
        sys_interval 1
      '';
    }
    (lib.mkIf config.boot.wipeRoot {
      dataDir = "/persist/mosquitto";
      extraConf = ''
        persistence true
        persistence_location /persist/mosquitto/data/
      '';
    })
  ];
}
