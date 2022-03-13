{config, pkgs, lib, ...}:
let 
  cfg = config.services.grafana-proxy;
in {
  options = {
    services.grafana-proxy = {
      enable = lib.mkEnableOption "grafana-proxy";
      endpoint = lib.mkOption {
        type = lib.types.str;
        example = "localhost:3000";
        description = ''
          Endpoint running grafana
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "vkleen-acme@17220103.de";
      };
    };
    services.nginx = {
      enable = true;
      clientMaxBodySize = "400M";
      virtualHosts = {
        "grafana.kleen.org" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${cfg.endpoint}";
            proxyWebsockets = true;
          };
          extraConfig = ''
            access_log off;
          '';
        };
      };
    };
  };
}
