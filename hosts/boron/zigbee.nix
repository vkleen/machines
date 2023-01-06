{ flake, config, ... }:
{
  age.secrets."zigbee2mqtt" = {
    file = ../../secrets/zigbee2mqtt.age;
    owner = "zigbee2mqtt";
  };
  age.secrets."mqtt2prom" = {
    file = ../../secrets/mqtt2prom.age;
  };
  services.zigbee2mqtt = {
    enable = true;
    dataDir = "/persist/zigbee2mqtt";
    settings = {
      frontend = {
        port = 8080;
        host = "localhost";
      };
      serial = {
        port = "/dev/ttyUSB0";
        rtscts = false;
      };
      mqtt = {
        base_topic = "zigbee";
        server = "mqtt://localhost:1883";
        user = "!secret user";
        password = "!secret password";
        version = 5;
      };
      advanced = {
        pan_id = 49623;
        ext_pan_id = [ 54 82 43 172 129 13 132 91 ];
        network_key = "!secret network_key";
      };
    };
  };

  services.prometheus.exporters.mqtt2prometheus = {
    enable = true;
    mqttUser = "mqtt2prom";
    mqttPasswordFile = "$CREDENTIALS_DIRECTORY/mqtt2prom";
    listenAddress = "localhost";
    settings = {
      mqtt = {
        server = "tcp://127.0.0.1:1883";
        topic_path = "zigbee/th/+";
      };
      cache = {
        timeout = "24h";
      };
      metrics = [
        {
          prom_name = "battery";
          mqtt_name = "battery";
          help = "Remaining battery in %";
          type = "gauge";
        }
        {
          prom_name = "temperature";
          mqtt_name = "temperature";
          help = "Measured temperature in °C";
          type = "gauge";
        }
        {
          prom_name = "humidity";
          mqtt_name = "humidity";
          help = "Measured relative humidity in %";
          type = "gauge";
        }
        {
          prom_name = "voltage";
          mqtt_name = "voltage";
          help = "Battery voltage in mV";
          type = "gauge";
        }
        {
          prom_name = "linkquality";
          mqtt_name = "linkquality";
          help = "Link quality indicator";
          type = "gauge";
        }
      ];
    };
  };
  systemd.services."prometheus-mqtt2prometheus-exporter".serviceConfig.LoadCredential = [
    "mqtt2prom:/run/agenix/mqtt2prom"
  ];
}
