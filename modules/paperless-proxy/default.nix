{config, pkgs, lib, ...}:
let 
  cfg = config.services.paperless-proxy;
in {
  options = {
    services.paperless-proxy = {
      enable = lib.mkEnableOption "paperless-proxy";
      endpoint = lib.mkOption {
        type = lib.types.str;
        example = "localhost:3000";
        description = ''
          Endpoint running paperless
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
        "paperless.kleen.org" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${cfg.endpoint}";
            proxyWebsockets = true;
          };
          extraConfig = ''
            access_log off;

            if ($ssl_client_verify != "SUCCESS") { return 403; }
            ssl_client_certificate ${../../secrets/paperless/client_ca.pem};
            ssl_verify_depth 2;
            ssl_verify_client on;
          '';
        };
      };
    };
  };
}
