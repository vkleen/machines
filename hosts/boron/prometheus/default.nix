{ config, flake, pkgs, lib, ... }:
let
  relabelHosts = [
    {
      source_labels = [ "__address__" ];
      target_label = "instance";
      regex = "localhost(:[0-9]+)?";
      replacement = "boron";
    }
  ];

  zteExporterPort = 9900;
in
{
  config = {
    services.prometheus = {
      enable = true;
      stateDir = "prometheus";
      listenAddress = "127.0.0.1";
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ ];
        };
        systemd = {
          enable = true;
          extraFlags = [
            "--systemd.collector.unit-include=(lte-dhcp|pppd-telekom|corerad)\.service"
          ];
        };
        mikrotik = {
          enable = true;
          extraFlags = [ "-timeout=1s" "-tls=true" "-insecure=true" ];
          configuration = {
            devices = [
              {
                name = "lithium";
                address = "192.168.88.1";
                user = "prometheus";
                password = "$MIKROTIK_PASSWORD";
              }
            ];
            features = {
              bgp = true;
              capsman = true;
              conntrack = true;
              dhcpl = true;
              dhcp = true;
              firmware = true;
              health = true;
              ipsec = true;
              lte = true;
              monitor = true;
              netwatch = true;
              optics = true;
              pools = true;
              routes = true;
              wlanif = true;
              wlansta = true;
            };
          };
        };
      };
      globalConfig = {
        evaluation_interval = "1s";
      };
      scrapeConfigs = [
        {
          job_name = "prometheus";
          static_configs = [
            { targets = [ "localhost:${builtins.toString config.services.prometheus.port}" ]; }
          ];
          relabel_configs = relabelHosts;
          scrape_interval = "1s";
        }
        {
          job_name = "mqtt";
          static_configs = [
            { targets = [ "localhost:${builtins.toString config.services.prometheus.exporters.mqtt2prometheus.port}" ]; }
          ];
          relabel_configs = relabelHosts;
          scrape_interval = "15s";
        }
        {
          job_name = "node";
          static_configs = [
            { targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ]; }
          ];
          relabel_configs = relabelHosts;
          scrape_interval = "5s";
        }
        {
          job_name = "systemd";
          static_configs = [
            { targets = [ "localhost:${toString config.services.prometheus.exporters.systemd.port}" ]; }
          ];
          relabel_configs = relabelHosts;
          scrape_interval = "5s";
        }
        {
          job_name = "loki";
          static_configs = [
            { targets = [ "localhost:${toString config.services.loki.configuration.server.http_listen_port}" ]; }
          ];
          relabel_configs = relabelHosts;
          scrape_interval = "1s";
        }
        {
          job_name = "promtail";
          static_configs = [
            { targets = [ "localhost:${toString config.services.promtail.configuration.server.http_listen_port}" ]; }
          ];
          relabel_configs = relabelHosts;
          scrape_interval = "1s";
        }
        {
          job_name = "zte";
          static_configs = [
            { targets = [ "localhost:${toString zteExporterPort}" ]; }
          ];
          relabel_configs = [
            {
              replacement = "telekom";
              target_label = "instance";
            }
          ];
          scrape_interval = "15s";
        }
        {
          job_name = "lithium";
          static_configs = [
            { targets = [ "localhost:${toString config.services.prometheus.exporters.mikrotik.port}" ]; }
          ];
          scrape_interval = "15s";
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
      settings.security.admin_password = "$__file{/run/credentials/grafana.service/admin-password}";
      settings.security.secretKeyFile = "$__file{/run/credentials/grafana.service/secret-key}";
    };
    systemd.services.grafana.serviceConfig.LoadCredential = [
      "admin-password:/run/agenix/grafana-admin-password"
      "secret-key:/run/agenix/grafana-secret-key"
    ];
    networking.firewall.interfaces."wg-europium".allowedTCPPorts = [ config.services.grafana.port ];
    networking.firewall.interfaces."neodymium".allowedTCPPorts = [ config.services.grafana.port ];
    age.secrets = {
      "grafana-admin-password".file = ../../../secrets/grafana/admin-password.age;
      "grafana-secret-key".file = ../../../secrets/grafana/secret-key.age;
      "zte-credentials".file = ../../../secrets/zte-credentials.age;
      "lithium-prometheus-credentials".file = ../../../secrets/lithium-prometheus-credentials.age;
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
          {
            from = "2022-01-01";
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
          {
            job_name = "journal";
            journal = {
              json = true;
              max_age = "12h";
              path = "/var/log/journal";
              labels = {
                job = "systemd-journal";
              };
            };
            relabel_configs = [
              {
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }
              {
                source_labels = [ "__journal__hostname" ];
                target_label = "nodename";
              }
            ];
          }
        ];
      };
    };

    systemd.services."prometheus-zte-exporter@192.168.1.1" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        PrivateTmp = true;
        WorkingDirectory = "/tmp";
        DynamicUser = true;
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";

        Type = "simple";
        ExecStart = "${pkgs.zte-prometheus-exporter}/bin/zte-prometheus-exporter";
        Environment = "ZTE_BASEURL=http://%I ZTE_HOSTNAME=localhost ZTE_PORT=${toString zteExporterPort}";
        EnvironmentFile = "/run/agenix/zte-credentials";
      };
    };

    systemd.services."prometheus-mikrotik-exporter".serviceConfig =
      let
        cfg = config.services.prometheus.exporters.mikrotik;
        configFile = "${pkgs.writeText "mikrotik-exporter.json" (builtins.toJSON cfg.configuration)}";
        finalConfigFile = "$RUNTIME_DIRECTORY/mikrotik-exporter.json";
      in
      {
        RuntimeDirectoryMode = "0700";
        RuntimeDirectory = "prometheus-mikrotik-exporter";
        LoadCredential = [
          "credentials:/run/agenix/lithium-prometheus-credentials"
        ];
        ExecStart = lib.mkForce (pkgs.writeShellScript "prometheus-mikrotik-exporter-start" ''
          umask 077
          export $(xargs < "''${CREDENTIALS_DIRECTORY}"/credentials)
          ${pkgs.envsubst}/bin/envsubst -i "${configFile}" > ${finalConfigFile}
          exec ${pkgs.prometheus-mikrotik-exporter}/bin/mikrotik-exporter \
            -config-file=${finalConfigFile} \
            -port=${cfg.listenAddress}:${toString cfg.port} \
            ${lib.concatStringsSep " " cfg.extraFlags}
        '');
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
