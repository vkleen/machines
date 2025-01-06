{ config, pkgs, lib, ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts = {
      "www.kleen.org" = {
        enableACME = true;
        forceSSL = true;
        default = true;
        listen = [
          { addr = "0.0.0.0"; port = 80; ssl = false; } 
          { addr = "[::]"; port = 80; ssl = false; } 
          { addr = "0.0.0.0"; port = 8443; ssl = true; } 
          { addr = "[::]"; port = 8443; ssl = true; } 
        ];
        locations."/".return = "404";
      };
      "math.kleen.org" = {
        enableACME = true;
        forceSSL = true;
        listen = [
          { addr = "0.0.0.0"; port = 80; ssl = false; } 
          { addr = "[::]"; port = 80; ssl = false; } 
          { addr = "0.0.0.0"; port = 8443; ssl = true; } 
          { addr = "[::]"; port = 8443; ssl = true; } 
        ];
        root = "/sites/math.kleen.org/";
        locations."= /favicon.ico".return = "204";
      };
      "beta.math.kleen.org" = {
        enableACME = true;
        forceSSL = true;
        listen = [
          { addr = "0.0.0.0"; port = 80; ssl = false; } 
          { addr = "[::]"; port = 80; ssl = false; } 
          { addr = "0.0.0.0"; port = 8443; ssl = true; } 
          { addr = "[::]"; port = 8443; ssl = true; } 
        ];
        root = "/sites/beta.math.kleen.org";
        locations."= /favicon.ico".return = "204";
      };
      "www.as210286.net" = {
        listen = [
          { addr = "0.0.0.0"; port = 80; ssl = false; } 
          { addr = "[::]"; port = 80; ssl = false; } 
          { addr = "0.0.0.0"; port = 8443; ssl = true; } 
          { addr = "[::]"; port = 8443; ssl = true; } 
        ];
        forceSSL = true;
        sslCertificate = "/run/credentials/nginx.service/as210286.net.pem";
        sslCertificateKey = "/run/credentials/nginx.service/as210286.net.key.pem";
        sslTrustedCertificate = "/run/credentials/nginx.service/as210286.net.chain.pem";
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=63072000" always;
        '';
        locations."/".return = "404";
      };
      "as210286.net" = {
        listen = [
          { addr = "0.0.0.0"; port = 80; ssl = false; } 
          { addr = "[::]"; port = 80; ssl = false; } 
          { addr = "0.0.0.0"; port = 8443; ssl = true; } 
          { addr = "[::]"; port = 8443; ssl = true; } 
        ];
        forceSSL = true;
        sslCertificate = "/run/credentials/nginx.service/as210286.net.pem";
        sslCertificateKey = "/run/credentials/nginx.service/as210286.net.key.pem";
        sslTrustedCertificate = "/run/credentials/nginx.service/as210286.net.chain.pem";
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=63072000" always;
        '';
        locations."/".return = "404";
      };
      "grafana.kleen.org" = {
        listen = [
          { addr = "0.0.0.0"; port = 80; ssl = false; } 
          { addr = "[::]"; port = 80; ssl = false; } 
          { addr = "0.0.0.0"; port = 8443; ssl = true; } 
          { addr = "[::]"; port = 8443; ssl = true; } 
        ];
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://10.172.50.136:2342";
          proxyWebsockets = true;
        };
      };
    };
    streamConfig = ''
      upstream boron {
        server 10.172.50.136:443;
      }

      map $ssl_preread_server_name $targetBackend {
        radicale.as210286.net boron;
        paperless.kleen.org boron;
        default 127.0.0.1:8443;
      }

      server {
        listen 0.0.0.0:443 reuseport;
        listen [::0]:443 reuseport;
        proxy_connect_timeout 1s;
        proxy_timeout 3s;

        proxy_pass $targetBackend;
        ssl_preread on;
      }
    '';
  };

  systemd.services.nginx = {
    preStart = lib.mkForce config.services.nginx.preStart;
    serviceConfig = {
      ExecReload = lib.mkForce [
        "${pkgs.coreutils}/bin/kill -HUP $MAINPID"
      ];
      LoadCredential = [
        "as210286.net.key.pem:${config.security.acme.certs."as210286.net".directory}/key.pem"
        "as210286.net.pem:${config.security.acme.certs."as210286.net".directory}/fullchain.pem"
        "as210286.net.chain.pem:${config.security.acme.certs."as210286.net".directory}/chain.pem"
      ];
    };
  };


  security.acme.domains = {
    "grafana.kleen.org" = {};
    "as210286.net" = {
      wildcard = true;
      certCfg = {
        postRun = ''
          ${pkgs.systemd}/bin/systemctl try-restart nginx.service
        '';
      };
    };
  };
}
