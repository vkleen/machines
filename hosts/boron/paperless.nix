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

    systemd.services.paperless-scheduler = let 
      script = (pkgs.writeShellScriptBin "paperless-scheduler-start" ''
        set -e
        export PAPERLESS_SECRET_KEY=$(${pkgs.coreutils}/bin/cat "${config.services.paperless.dataDir}/secret-key")
        ${config.services.paperless.package}/bin/celery --app paperless beat --loglevel INFO
      '').overrideAttrs (_: {
        name = "unit-script-paperless-scheduler-start";
      });
    in {
      after = ["var-lib-paperless.mount"];
      serviceConfig = {
        ExecStart = lib.mkForce "${script}/bin/paperless-scheduler-start";
        RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" ];
      };
    };

    systemd.services.paperless-task-queue = let 
      script = (pkgs.writeShellScriptBin "paperless-task-queue-start" ''
        set -e
        export PAPERLESS_SECRET_KEY=$(${pkgs.coreutils}/bin/cat "${config.services.paperless.dataDir}/secret-key")
        ${config.services.paperless.package}/bin/celery --app paperless worker --loglevel INFO
      '').overrideAttrs (_: {
        name = "unit-script-paperless-task-queue-start";
      });
    in {
      after = ["var-lib-paperless.mount"];
      serviceConfig = {
        ExecStart = lib.mkForce "${script}/bin/paperless-task-queue-start";
        RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" ];
      };
    };


    systemd.services.paperless-consumer = let 
      script = (pkgs.writeShellScriptBin "paperless-consumer-start" ''
        set -e
        export PAPERLESS_SECRET_KEY=$(${pkgs.coreutils}/bin/cat "${config.services.paperless.dataDir}/secret-key")
        ${config.services.paperless.package}/bin/paperless-ngx document_consumer
      '').overrideAttrs (_: {
        name = "unit-script-paperless-consumer-start";
      });
    in {
      after = ["var-lib-paperless.mount"];
      serviceConfig = {
        ExecStart = lib.mkForce "${script}/bin/paperless-consumer-start";
        RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" ];
      };
    };


    systemd.services.paperless-web = let
      script = (pkgs.writeShellScriptBin "paperless-web-start" ''
        set -e
        export PAPERLESS_SECRET_KEY=$(${pkgs.coreutils}/bin/cat "${config.services.paperless.dataDir}/secret-key")
        ${config.services.paperless.package.python.pkgs.gunicorn}/bin/gunicorn \
          -c ${config.services.paperless.package}/lib/paperless-ngx/gunicorn.conf.py paperless.asgi:application
      '').overrideAttrs (_: {
        name = "unit-script-paperless-web-start";
      });
    in {
      after = ["var-lib-paperless.mount"];
      requires = [ "paperless-web.socket" ];
      serviceConfig = {
        ExecStart = lib.mkForce "${script}/bin/paperless-web-start";
        AmbientCapabilities = lib.mkForce "";
        CapabilityBoundingSet = lib.mkForce "";
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
