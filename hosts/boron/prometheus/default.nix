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
    fileSystems = {
      "/var/lib/prometheus" = {
        device = "/persist/prometheus";
        options = [ "bind" ];
      };
      "/var/lib/grafana" = {
        device = "/persist/grafana";
        options = [ "bind" ];
      };
    };
  };
}
