{ flake, config, lib, pkgs, ... }:
{
  imports = [
    ../../secrets/mosquitto.nix
  ];
  age.secrets."mqtt.pem".file = ../../secrets/mosquitto/mqtt.pem.age;
  age.secrets."mqtt.key".file = ../../secrets/mosquitto/mqtt.key.age;
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
            cafile = "/run/secrets/mqtt.pem";
            certfile = "/run/secrets/mqtt.pem";
            keyfile = "/run/secrets/mqtt.key";
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
