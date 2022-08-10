{ flake, config, pkgs, hostName, lib, ... }:
{
  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ "127.0.0.1:5232" "[::1]:5232" ];
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = "/run/credentials/radicale.service/users";
        htpasswd_encryption = "bcrypt";
      };
      storage = {
        filesystem_folder = "/var/lib/radicale/collections";
      };
      web = {
        type = "none";
      };
    };
  };

  systemd.services.radicale = let
    confFile = (pkgs.formats.ini {
      listToValue = lib.concatMapStringsSep ", " (lib.generators.mkValueStringDefault { });
    }).generate "radicale.conf" config.services.radicale.settings;

    unitScript = pkgs.writeShellScript "radicale-start" ''
      set -e
      ${pkgs.python3Packages.gunicorn}/bin/gunicorn \
        --bind=fd://3 \
        --env RADICALE_CONFIG=${confFile} \
        radicale:application
    '';
  in {
    after = ["var-lib-radicale.mount"];
    requires = ["radicale.socket"];
    serviceConfig = {
      RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" ];
      ExecStart = lib.mkForce "${unitScript}";
      LoadCredential = [
        "users:/run/agenix/radicale/users"
      ];
      SystemCallFilter = [ "@setuid" ];
    };
    environment = {
      PYTHONPATH = "${pkgs.radicale.pythonPath}:${pkgs.python3.pkgs.cffi}/${pkgs.python3.sitePackages}:${pkgs.radicale}/${pkgs.python3.sitePackages}";
    };
  };

  systemd.sockets."radicale" = {
    description = "Socket for radicale";
    wantedBy = [ "nginx.service" "sockets.target" ];
    listenStreams = [ "/run/nginx/radicale.sock" ];
    socketConfig = {
      SocketUser = config.services.nginx.user;
      SocketMode = "0600";
    };
  };

  security.acme.domains."radicale.as210286.net" = {
  };

  age.secrets."radicale/users" = {
    file = ../../secrets/radicale/users.age;
    mode = "0400";
  };

  fileSystems."/var/lib/radicale" = {
    device = "/persist/radicale";
    options = [ "bind" ];
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    upstreams."radicale".servers = {
      "unix:/run/nginx/radicale.sock" = {};
    };

    virtualHosts."radicale.as210286.net" = {
      listen = lib.mkForce [
        { addr = "10.172.50.136"; port = 443; ssl = true; }
      ];
      onlySSL = true;
      sslCertificate = "/run/credentials/nginx.service/radicale.as210286.net.pem";
      sslCertificateKey = "/run/credentials/nginx.service/radicale.as210286.net.key.pem";
      sslTrustedCertificate = "/run/credentials/nginx.service/radicale.as210286.net.chain.pem";
      extraConfig = ''
        access_log off;

        add_header Strict-Transport-Security "max-age=63072000" always;

        if ($ssl_client_verify != "SUCCESS") { return 403; break; }
        ssl_client_certificate ${../../secrets/radicale/client_ca.pem};
        ssl_verify_depth 2;
        ssl_verify_client optional;
      '';
      locations."/" = {
        proxyPass = "http://radicale/";
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
        "radicale.as210286.net.key.pem:${config.security.acme.certs."radicale.as210286.net".directory}/key.pem"
        "radicale.as210286.net.pem:${config.security.acme.certs."radicale.as210286.net".directory}/fullchain.pem"
        "radicale.as210286.net.chain.pem:${config.security.acme.certs."radicale.as210286.net".directory}/chain.pem"
      ];
    };
  };

}
