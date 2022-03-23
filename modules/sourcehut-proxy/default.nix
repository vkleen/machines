{config, pkgs, lib, ...}:
let 
  cfg = config.services.sourcehut-proxy;
in {
  options = {
    services.sourcehut-proxy = {
      enable = lib.mkEnableOption "sourcehut-proxy";
      endpoints = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        example = {
          git = "localhost:3000";
          meta = "localhost:3001";
        };
        description = ''
          Service to endpoint mapping
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
      recommendedProxySettings = true;
      virtualHosts = lib.flip lib.mapAttrs' cfg.endpoints (n: ep:
        lib.nameValuePair "${n}.sr.ht.kleen.org" {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://${ep}";
          };
          extraConfig = ''
            access_log off;
          '';
        });
    };
  };
}
