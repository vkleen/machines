{config, pkgs, lib, ...}:
let 
  cfg = config.services.rmfakecloud-proxy;
in {
  options = {
    services.rmfakecloud-proxy = {
      enable = lib.mkEnableOption "rmfakecloud-proxy";
      endpoint = lib.mkOption {
        type = lib.types.str;
        example = "localhost:3000";
        description = ''
          Endpoint running rmfakecloud
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
        "remarkable.kleen.org" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${cfg.endpoint}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_read_timeout 1d;
              proxy_send_timeout 1d;
            '';
          };
          extraConfig = ''
            access_log off;
          '';
        };
      };
    };
  };
}
