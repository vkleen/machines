{ flake, config, pkgs, lib, ...}:
{
  config = {
    services.paperless = {
      enable = true;
      address = "127.0.0.1";
      port = 58080;
      passwordFile = "/run/agenix/paperless/admin-pass";
      extraConfig = {
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_URL = "https://paperless.kleen.org";
        PAPERLESS_CONSUMER_RECURSIVE = "true";
        PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = "true";
        PAPERLESS_CONSUMER_ENABLE_BARCODES = "true";
        GUNICORN_CMD_ARGS = "--bind=fd://3";
      };
    };
    systemd.services.paperless-scheduler.after = ["var-lib-paperless.mount"];
    systemd.services.paperless-consumer.after = ["var-lib-paperless.mount"];
    systemd.services.paperless-web.after = ["var-lib-paperless.mount"];

    age.secrets."paperless/admin-pass" = {
      file = ../../secrets/paperless/admin-pass.age;
      mode = "0400";
    };

    age.secrets."paperless/secret-key" = {
      file = ../../secrets/paperless/secret-key.age;
      mode = "0400";
    };

    systemd.services.paperless-copy-secret = {
      requiredBy = [ "paperless-scheduler.service" ];
      before = [ "paperless-scheduler.service" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.coreutils}/bin/install --mode 400 --owner '${config.services.paperless.user}' --compare \
            /run/agenix/paperless/secret-key '${config.services.paperless.dataDir}/secret-key'
        '';
        Type = "oneshot";
      };
    };

    systemd.services.paperless-scheduler = {
      script = lib.mkBefore ''
        export PAPERLESS_SECRET_KEY=$(${pkgs.coreutils}/bin/cat "${config.services.paperless.dataDir}/secret-key")
      '';
      wantedBy = lib.mkForce [];
      serviceConfig = {
        RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" ];
      };
    };
    systemd.services.paperless-consumer = {
      script = lib.mkBefore ''
        export PAPERLESS_SECRET_KEY=$(${pkgs.coreutils}/bin/cat "${config.services.paperless.dataDir}/secret-key")
      '';
      serviceConfig = {
        RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" ];
      };
    };
    systemd.services.paperless-web = {
      script = lib.mkBefore ''
        export PAPERLESS_SECRET_KEY=$(${pkgs.coreutils}/bin/cat "${config.services.paperless.dataDir}/secret-key")
      '';
      requires = [ "paperless-web.socket" ];
      serviceConfig = {
        AmbientCapabilities = lib.mkForce "";
        CapabilityBoundingSet = lib.mkForce "";
        SystemCallFilter = [ "mbind" ];
        RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" ];
      };
    };

    systemd.sockets."paperless-web" = {
      description = "Socket for paperless-web";
      wantedBy = [ "nginx.service" "sockets.target" ];
      listenStreams = [ "/run/nginx/paperless.sock" ];
      socketConfig = {
        SocketUser = config.services.nginx.user;
        SocketMode = "0600";
      };
    };

    fileSystems."/var/lib/paperless" = {
      device = "/persist/paperless";
      options = [ "bind" ];
    };

    security.acme.domains."paperless.kleen.org" = {
    };

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      upstreams."paperless".servers = {
        "unix:/run/nginx/paperless.sock" = {};
      };

      virtualHosts."paperless.kleen.org" = {
        listen = lib.mkForce [
          { addr = "10.172.50.136"; port = 443; ssl = true; }
        ];
        onlySSL = true;
        sslCertificate = "/run/credentials/nginx.service/paperless.kleen.org.pem";
        sslCertificateKey = "/run/credentials/nginx.service/paperless.kleen.org.key.pem";
        sslTrustedCertificate = "/run/credentials/nginx.service/paperless.kleen.org.chain.pem";
        extraConfig = ''
          access_log off;

          add_header Strict-Transport-Security "max-age=63072000" always;

          if ($ssl_client_verify != "SUCCESS") { return 403; break; }
          ssl_client_certificate ${../../secrets/paperless/client_ca.pem};
          ssl_verify_depth 2;
          ssl_verify_client optional;
        '';
        locations."/" = {
          proxyPass = "http://paperless/";
        };
      };
    };

    networking.firewall.interfaces."neodymium".allowedTCPPorts = [ 443 ];

    systemd.services.nginx = {
      preStart = lib.mkForce config.services.nginx.preStart;
      serviceConfig = {
        ExecReload = lib.mkForce [
          "${pkgs.coreutils}/bin/kill -HUP $MAINPID"
        ];
        LoadCredential = [
          "paperless.kleen.org.key.pem:${config.security.acme.certs."paperless.kleen.org".directory}/key.pem"
          "paperless.kleen.org.pem:${config.security.acme.certs."paperless.kleen.org".directory}/fullchain.pem"
          "paperless.kleen.org.chain.pem:${config.security.acme.certs."paperless.kleen.org".directory}/chain.pem"
        ];
      };
    };
  };
}
