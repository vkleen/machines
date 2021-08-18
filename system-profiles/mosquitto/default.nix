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
        { host = "";
          port = 8883;
          ssl = {
            enable = true;
            cafile = "/persist/mosquitto/mqtt.pem";
            certfile = "/persist/mosquitto/mqtt.pem";
            keyfile = "/persist/mosquitto/mqtt.key";
          };
          extraConf = ''
            tls_version tlsv1.3
          '';
        }
      ];
      users = {
        "relayd" = {
          acl = [
            "topic readwrite relays/#"
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
