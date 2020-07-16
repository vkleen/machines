{config, pkgs, lib, ...}:
{
  imports = [
    ./secrets.nix
  ];
  disabledModules = [ ];

  services.matrix-synapse = {
    enable = true;
    server_name = "kleen.org";
    public_baseurl = "https://matrix.kleen.org/";
    # database_type = "sqlite3";
    database_type = "psycopg2";
    database_name = "matrix_synapse";
    database_user = "matrix_synapse";
    listeners = [
      {
        port = 8008;
        bind_address = "::1";
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [
          { names = [ "client" "federation" ]; compress = false; }
        ];
      }
    ];
    rc_message_burst_count = "100";
    rc_messages_per_second = "100";
    extraConfig = ''
      max_upload_size: "100M"
    '';
  };

  security.acme = {
    acceptTerms = true;
    email = "vkleen-acme@17220103.de";
    certs = {
      "matrix.kleen.org" = {
        postRun = ''
          systemctl reload nginx.service
        '';
      };
    };
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = false;
    authentication = lib.mkForce ''
      local matrix_synapse matrix_synapse peer map=matrix
      local all postgres peer
      local all all reject
    '';
    identMap = lib.mkForce ''
      matrix matrix-synapse matrix_synapse
    '';
    initialScript = pkgs.writeText "psql-init" ''
      CREATE ROLE matrix_synapse LOGIN;
      CREATE DATABASE matrix_synapse
        ENCODING 'UTF8'
        LC_COLLATE='C'
        LC_CTYPE='C'
        template=template0
        OWNER matrix_synapse;
    '';
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "kleen.org" = {
        enableACME = true;
        addSSL = true;
        locations."= /.well-known/matrix/server".extraConfig =
          let server = { "m.server" = "matrix.kleen.org:443"; };
          in ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';
        locations."= /.well-known/matrix/client".extraConfig =
          let client = {
                "m.homeserver" = { "base_url" = "https://matrix.kleen.org"; };
                "m.identity_server" = { "base_url" = "https://vector.im"; };
              };
          in ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '${builtins.toJSON client}';
          '';
        locations."/_matrix" = {
          proxyPass = "http://[::1]:8008";
        };
        locations."/".return = "301 https://www.kleen.org$request_uri";
        extraConfig = ''
          access_log off;
        '';
      };
      "matrix.kleen.org" = {
        enableACME = true;
        forceSSL = true;
        locations."/".extraConfig = ''
          return 404;
        '';
        locations."/_matrix" = {
          proxyPass = "http://[::1]:8008";
        };
        locations."/_synapse" = {
          proxyPass = "http://[::1]:8008";
        };
        listen = [
          { addr = "0.0.0.0"; port = 8448; ssl = true; }
          { addr = "[::]"; port = 8448; ssl = true; }
          { addr = "0.0.0.0"; port = 443; ssl = true; }
          { addr = "[::]"; port = 443; ssl = true; }
        ];
        extraConfig = ''
          access_log off;
        '';
      };
      "riot.kleen.org" = {
        enableACME = true;
        forceSSL = true;

        root = pkgs.riot-web.override {
          conf = {
            default_server_config."m.homeserver" ={
              "base_url" = "https://kleen.org";
              "server_name" = "kleen.org";
            };
          };
        };
        extraConfig = ''
          access_log off;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 8448 ];
}
