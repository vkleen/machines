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
    };
  };

  systemd.services.radicale = {
    after = ["var-lib-radicale.mount"];
    serviceConfig = {
      IPAddressAllow = "localhost";
      IPAddressDeny = "any";
      LoadCredential = [
        "users:/run/agenix/radicale/users"
      ];
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
        proxyPass = "http://localhost:5232";
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
