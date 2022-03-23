{ flake, lib, config, pkgs, ... }:
{
  config = lib.mkMerge [
    {
      services.sourcehut = {
        enable = true;
        postgresql.enable = true;
        redis.enable = true;
        nginx.enable = true;

        git = {
          enable = true;
        };
        meta = {
          enable = true;
        };
        paste = {
          enable = true;
        };

        settings = lib.mkMerge ([ {
            "sr.ht" = {
              global-domain = "sr.ht.kleen.org";
              network-key = "/run/agenix/sourcehut/network-key";
              service-key = "/run/agenix/sourcehut/service-key";
              owner-email = "sr.ht@kleen.org";
              owner-name = "Viktor Kleen";
              sitename = "sr.ht.kleen.org";
              environment = "production";
            };
            "mail" = {
              smtp-host = "localhost";
              stmp-encryption = "insecure";
              smtp-auth = "none";
              smtp-port = 25;
              smtp-from = "srht@kleen.org";
              error-to = "vkleen-srht@17220103.de";
              error-from = "srht@kleen.org";
              pgp-privkey = "$CREDENTIALS_DIRECTORY/email-key";
              pgp-pubkey = "${./email-key.pub}";
              pgp-key-id = "CD7AD768C1B1344C96E7620BC6697B558070A133";
            };
            "git.sr.ht" = {
              oauth-client-id = "cb540e13154c59df";
              oauth-client-secret = "/run/agenix/sourcehut/git-oauth-client-secret";
              api-origin = "http://localhost:5101";
            };
            "paste.sr.ht" = {
              oauth-client-id = "bf90853f5ae6c92c";
              oauth-client-secret = "/run/agenix/sourcehut/paste-oauth-client-secret";
            };
            "meta.sr.ht::settings" = {
              registration = false;
            };
            "meta.sr.ht::auth" = {
              auth-method = "builtin";
            };
            "meta.sr.ht" = {
              api-origin = "http://localhost:5100";
            };
            webhooks.private-key = "/run/agenix/sourcehut/webhooks-private-key";
          } ] ++ (lib.flip lib.lists.map config.services.sourcehut.services (srv: {
            "${srv}.sr.ht".internal-origin = lib.mkDefault "http://localhost";
          })));
      };

      services.postgresql = {
        enable = true;
        enableTCPIP = false;
        settings.unix_socket_permissions = "0770";
      };
      services.nginx = {
        enable = true;
        virtualHosts."git.sr.ht.kleen.org" = {
          listen = lib.mkForce [{ addr = "0.0.0.0"; port = 8081; }];
          forceSSL = lib.mkForce false;
        };
        virtualHosts."meta.sr.ht.kleen.org" = {
          listen = lib.mkForce [{ addr = "0.0.0.0"; port = 8082; }];
          forceSSL = lib.mkForce false;
        };
        virtualHosts."paste.sr.ht.kleen.org" = {
          listen = lib.mkForce [{ addr = "0.0.0.0"; port = 8083; }];
          forceSSL = lib.mkForce false;
        };
      };
      networking.firewall.interfaces."wg-europium".allowedTCPPorts = [
        8081 8082 8083
      ];

      services.postfix = {
        enableSmtp = lib.mkForce true;
        config = {
          inet_interfaces = "loopback-only";
        };
      };

      systemd.tmpfiles.rules = [
        # /var/log is owned by root
        "f /var/log/gitsrht-update-hook 0644 ${config.services.sourcehut.git.user} ${config.services.sourcehut.git.user} -"
        "f /var/log/gitsrht-shell 0644 ${config.services.sourcehut.git.user} ${config.services.sourcehut.git.user} -"
      ];

      systemd.services = let
        mkServiceConfig = name: lib.nameValuePair "${name}" {
          serviceConfig = let
            configIni = "/run/sourcehut/${name}/config.ini";
          in {
            ExecStartPre = lib.mkOrder 600 [("+" + pkgs.writeShellScript "${name}-credential-dir" ''
              mv ${configIni} ${configIni}.old
              ${pkgs.envsubst}/bin/envsubst -i ${configIni}.old > ${configIni}
            '')];
            LoadCredential = [
              "email-key:/run/agenix/sourcehut/email-key"
            ];
          };
        };

        mkServiceConfigNoEmail = name: lib.nameValuePair "${name}" {
          serviceConfig = let
            configIni = "/run/sourcehut/${name}/config.ini";
          in {
            ExecStartPre = lib.mkOrder 600 [("+" + pkgs.writeShellScript "${name}-remove-email-key" ''
              ${pkgs.gnused}/bin/sed -i -e '/^pgp-privkey/d' ${configIni}
            '')];
          };
        };
      in lib.listToAttrs [
          (mkServiceConfig "gitsrht")
          (mkServiceConfig "gitsrht-api")
          (mkServiceConfig "gitsrht-periodic")
          (mkServiceConfig "gitsrht-webhooks")
          (mkServiceConfig "metasrht")
          (mkServiceConfig "metasrht-api")
          (mkServiceConfig "metasrht-webhooks")
          (mkServiceConfigNoEmail "pastesrht")
          (mkServiceConfigNoEmail "pastesrht-api")
        ];

      age.secrets = {
        "sourcehut/network-key" = {
          file = ../../secrets/sourcehut/network-key.age;
          owner = "root";
        };
        "sourcehut/service-key" = {
          file = ../../secrets/sourcehut/service-key.age;
          owner = "root";
        };
        "sourcehut/git-oauth-client-secret" = {
          file = ../../secrets/sourcehut/git-oauth-client-secret.age;
          owner = "root";
        };
        "sourcehut/webhooks-private-key" = {
          file = ../../secrets/sourcehut/webhooks-private-key.age;
          owner = "root";
        };
        "sourcehut/email-key" = {
          file = ../../secrets/sourcehut/email-key.age;
          owner = "root";
        };
      };
    }
    (lib.mkIf config.boot.wipeRoot {
      services.postgresql = {
        dataDir = "/persist/postgres";
      };
      fileSystems."/var/lib/sourcehut" = {
        device = "/persist/sourcehut";
        options = [ "bind" ];
      };
    })
  ];
}
