{ flake, config, lib, pkgs, ... }:
let
  relayd = {
    "relayd" = {
      acl = [
        "readwrite relays/#"
      ];
      hashedPasswordFile = "/run/agenix/mosquitto/relayd-passwd";
    };
  };
  zigbee2mqtt = {
    "zigbee2mqtt" = {
      acl = [
        "readwrite zigbee/#"
      ];
      hashedPasswordFile = "/run/agenix/mosquitto/zigbee2mqtt-passwd";
    };
  };
  mqtt2prom = {
    "mqtt2prom" = {
      acl = [
        "read zigbee/#"
      ];
      hashedPasswordFile = "/run/agenix/mosquitto/mqtt2prom-passwd";
    };
  };
  root = {
    "root" = {
      acl = [
        "readwrite #"
        "readwrite $SYS/#"
      ];
      hashedPasswordFile = "/run/agenix/mosquitto/root-passwd";
    };
  };
in
{
  age.secrets."mqtt.pem" = {
    file = ../../secrets/mosquitto/mqtt.pem.age;
    owner = "mosquitto";
  };
  age.secrets."mqtt.key" = {
    file = ../../secrets/mosquitto/mqtt.key.age;
    owner = "mosquitto";
  };
  age.secrets."mosquitto/relayd-passwd" = {
    file = ../../secrets/mosquitto/relayd-passwd.age;
    owner = "mosquitto";
  };
  age.secrets."mosquitto/root-passwd" = {
    file = ../../secrets/mosquitto/root-passwd.age;
    owner = "mosquitto";
  };
  age.secrets."mosquitto/zigbee2mqtt-passwd" = {
    file = ../../secrets/mosquitto/zigbee2mqtt-passwd.age;
    owner = "mosquitto";
  };
  age.secrets."mosquitto/mqtt2prom-passwd" = {
    file = ../../secrets/mosquitto/mqtt2prom-passwd.age;
    owner = "mosquitto";
  };
  services.mosquitto = lib.mkMerge [
    {
      enable = true;
      listeners = [
        {
          address = "localhost";
          port = 1883;
          settings = {
            allow_anonymous = 0;
          };
          users = relayd // root // zigbee2mqtt // mqtt2prom;
        }
        {
          port = 8883;
          settings = {
            tls_version = "tlsv1.3";
            cafile = "/run/agenix/mqtt.pem";
            certfile = "/run/agenix/mqtt.pem";
            keyfile = "/run/agenix/mqtt.key";
            allow_anonymous = 0;
          };
          users = relayd;
        }
      ];
      settings = {
        sys_interval = 1;
      };
    }
    (lib.mkIf config.boot.wipeRoot {
      dataDir = "/persist/mosquitto";
      persistence = true;
      settings = {
        persistence_location = "/persist/mosquitto/data/";
      };
    })
  ];
  systemd.services.mosquitto.serviceConfig = {
    LoadCredential = [
      "relayd-passwd:/run/agenix/mosquitto/relayd-passwd"
      "root-passwd:/run/agenix/mosquitto/root-passwd"
    ];
  };
}
