{ flake, config, lib, pkgs, ... }:
{
  age.secrets."mqtt.pem" = {
    file = ../../secrets/mosquitto/mqtt.pem.age;
    owner = "mosquitto";
  };
  age.secrets."mqtt.key" = {
    file = ../../secrets/mosquitto/mqtt.key.age;
    owner = "mosquitto";
  };
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
          hashedPassword = "$6$tBx2f2kTMyLX8uLn$XA/IaMvz0SX8FYSrbRHgZMMEJJcBiES+RPIOU+oGe+z741UpD2RiiIdd8XqDvoJqv2u1yGsz41K78ZyGEOA0gA==";
        };
        "root" = {
          acl = [
            "topic readwrite #"
            "topic readwrite $SYS/#"
          ];
          hashedPassword = "$6$kOOa8HUBqEigUfT6$Ht5UOQ/vJrO3pj5bMOxl0qWO1LV+n+Ux2mhQjZWzkCyavWmqhlHdW58M77lr96LTXMnh21vv+jFsoQX5E5Cdpg==";
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
