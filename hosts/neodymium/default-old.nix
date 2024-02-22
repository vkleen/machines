{ flake, config, pkgs, hostName, lib, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./mailserver.nix
    ./math.kleen.org.nix
    ./dns
    ./tls
  ] ++ (with flake.nixosModules.systemProfiles; [
    hostid
    latest-linux
    no-coredump
    ntp-server
    ssh
  ]);

  nixpkgs = rec {
    system = "x86_64-linux";
  };

  nix.settings = {
    max-jobs = 4;
    cores = 1;
  };

  system.macnameNamespace = "wolkenheim.kleen.org";

  services.nginx = {
    virtualHosts = {
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
    } // (lib.listToAttrs (builtins.map
      (domain: lib.nameValuePair "${domain}" {
        listen = [
          { addr = "0.0.0.0"; port = 80; ssl = false; }
          { addr = "[::]"; port = 80; ssl = false; }
          { addr = "0.0.0.0"; port = 8443; ssl = true; }
          { addr = "[::]"; port = 8443; ssl = true; }
        ];
      }) [ "beta.math.kleen.org" "math.kleen.org" "www.kleen.org" ]));
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
        listen 443 reuseport;
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


  security.acme.domains."as210286.net" = {
    wildcard = true;
    certCfg = {
      postRun = ''
        ${pkgs.systemd}/bin/systemctl try-restart nginx.service
      '';
    };
  };
}
