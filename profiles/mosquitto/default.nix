{ flake, config, lib, pkgs, ... }:
{
  imports = [ flake.nixosModules.mosquitto ];
  services.mosquitto = {
    enable = true;
    listeners = [
      { host = "localhost";
        port = 1883;
      }
      { host = "localhost";
        port = 8883;
        ssl = {
          enable = true;
          cafile = "/persist/mosquitto/ca.pem";
          certfile = "/persist/mosquitto/cert.pem";
          keyfile = "/persist/mosquitto/key.pem";
        };
      }
    ];
    users = {
      "relayd" = {
        hashedPassword = "";
        acl = [
          "topic readwrite relays/+/status"
          "topic readwrite relays/+/+/diagnostic"
          "topic read relays/+/+/state"
        ];
      };
    };
    allowAnonymous = false;
    checkPasswords = true;
  } // (if config.boot.wipeRoot then {
    dataDir = "/persist/mosquitto";
  } else {});
}
