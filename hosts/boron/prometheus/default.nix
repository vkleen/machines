{ config, flake, pkgs, lib, ... }:
let
  relabelHosts = [
    { source_labels = ["__address__"];
      target_label = "instance";
      regex = "localhost(:[0-9]+)?";
      replacement = "boron";
    }
  ];
in {
  config = {
    services.prometheus = {
      enable = true;
      stateDir = "prometheus";
      listenAddress = "127.0.0.1";
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [];
        };
        systemd = {
          enable = true;
          extraFlags = [
            "--collector.unit-whitelist=(lte-dhcp|pppd-telekom|corerad)\.service"
          ];
        };
      };
      globalConfig = {
        evaluation_interval = "1s";
      };
      scrapeConfigs = [
        { job_name = "prometheus";
          static_configs = [
            { targets = ["localhost:${builtins.toString config.services.prometheus.port}"]; }
          ];
          relabel_configs = relabelHosts;
          scrape_interval = "1s";
        }
        { job_name = "node";
          static_configs = [
            { targets = ["localhost:${toString config.services.prometheus.exporters.node.port}"]; }
          ];
          relabel_configs = relabelHosts;
          scrape_interval = "5s";
        }
        { job_name = "systemd";
          static_configs = [
            { targets = ["localhost:${toString config.services.prometheus.exporters.systemd.port}"]; }
          ];
          relabel_configs = relabelHosts;
          scrape_interval = "5s";
        }
        { job_name = "loki";
          static_configs = [
            { targets = ["localhost:${toString config.services.loki.configuration.server.http_listen_port}"]; }
          ];
          relabel_configs = relabelHosts;
          scrape_interval = "1s";
        }
        { job_name = "promtail";
          static_configs = [
            { targets = ["localhost:${toString config.services.promtail.configuration.server.http_listen_port}"]; }
          ];
          relabel_configs = relabelHosts;
          scrape_interval = "1s";
        }
      ];
    };
    services.grafana = {
      enable = true;
      analytics.reporting.enable = false;
      domain = "grafana.kleen.org";
      protocol = "http";
      port = 2342;
      addr = "10.172.40.136";
      security.adminPasswordFile = "/run/credentials/grafana.service/admin-password";
      security.secretKeyFile = "/run/credentials/grafana.service/secret-key";
    };
    systemd.services.grafana.serviceConfig.LoadCredential = [
      "admin-password:/run/agenix/grafana-admin-password"
      "secret-key:/run/agenix/grafana-secret-key"
    ];
    networking.firewall.interfaces."wg-europium".allowedTCPPorts = [ config.services.grafana.port ];
    age.secrets = {
      "grafana-admin-password".file = ../../../secrets/grafana/admin-password.age;
      "grafana-secret-key".file = ../../../secrets/grafana/secret-key.age;
    };

    services.loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        server = {
          http_listen_port = 9094;
          grpc_listen_port = 9095;
        };
        common = {
          path_prefix = config.services.loki.dataDir;
          storage.filesystem = {
            chunks_directory = "${config.services.loki.dataDir}/chunks";
            rules_directory = "${config.services.loki.dataDir}/rules";
          };
          replication_factor = 1;
          ring = {
            instance_addr = "127.0.0.1";
            kvstore = {
              store = "inmemory";
            };
          };
        };
        ruler = {
          enable_api = true;
          storage = {
            type = "local";
            local.directory = "${config.services.loki.dataDir}/rules";
          };
          rule_path = "${config.services.loki.dataDir}/rules-temp";
          remote_write = {
            enabled = true;
            client.url = "http://localhost:${builtins.toString config.services.prometheus.port}/api/v1/write";
          };
          ring.kvstore.store = "inmemory";
        };
        schema_config.configs = [
          { from = "2022-01-01";
            store = "boltdb-shipper";
            object_store = "filesystem";
            schema = "v11";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };
    };
    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 9080;
          grpc_listen_port = 0;
        };
        clients = [
          { url = "http://localhost:${builtins.toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"; }
        ];
        scrape_configs = [
          { job_name = "journal";
            journal = {
              json = true;
              max_age = "12h";
              path = "/var/log/journal";
              labels = {
                job = "systemd-journal";
              };
            };
            relabel_configs = [
              { source_labels = ["__journal__systemd_unit"];
                target_label = "unit";
              }
              { source_labels = ["__journal__hostname"];
                target_label = "nodename";
              }
            ];
          }
        ];
      };
    };

    fileSystems = {
      "/var/lib/${config.services.prometheus.stateDir}" = {
        device = "/persist/prometheus";
        options = [ "bind" ];
      };
      "${config.services.grafana.dataDir}" = {
        device = "/persist/grafana";
        options = [ "bind" ];
      };
      "${config.services.loki.dataDir}" = {
        device = "/persist/loki";
        options = [ "bind" ];
      };
    };
  };
}
