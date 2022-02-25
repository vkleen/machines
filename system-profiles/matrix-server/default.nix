{ flake, pkgs, lib, config, ... }:
{
  services.matrix-synapse = {
    enable = true;
    server_name = "kleen.org";
    public_baseurl = "https://matrix.kleen.org";
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
    max_upload_size = "500M";
    extraConfigFiles = [ "/run/agenix/synapse-registration" "/run/agenix/synapse-coturn" ];
    turn_uris = [ "turns:turn.kleen.org?transport=udp" "turns:turn.kleen.org?transport=tcp" ];
    turn_user_lifetime = "1h";
  };

  age.secrets."synapse-registration" = {
    file = ../../secrets/synapse-registration.age;
    owner = "matrix-synapse";
  };
  age.secrets."synapse-coturn" = {
    file = ../../secrets/synapse-coturn.age;
    owner = "matrix-synapse";
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
        locations."~* ^(\\/_matrix|\\/_synapse\\/client)" = {
          proxyPass = "http://[::1]:8008";
          extraConfig = ''
            client_max_body_size 500M;
          '';
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

        root = pkgs.element-web.override {
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
      "turn.kleen.org" = {
        serverName = "turn.kleen.org";
        forceSSL = true;
        enableACME = true;
        http2 = false;
        locations."/".return = "404";
      };
    };
  };

  security.acme.certs = {
    "turn.kleen.org" = {
      email = "vkleen-zerossl@17220103.de";
      server = "https://acme.zerossl.com/v2/DV90";
      extraLegoFlags = [
        "--eab" "--kid" "dummy" "--hmac" "dummy"
      ];
    };
  };

  services.coturn = {
    enable = true;
    no-cli = true;
    no-tcp-relay = true;
    min-port = 49000;
    max-port = 50000;
    use-auth-secret = true;
    static-auth-secret-file = "/run/agenix/coturn-auth";
    realm = "turn.kleen.org";
    cert = "/run/credentials/coturn.service/turn.kleen.org.pem";
    pkey = "/run/credentials/coturn.service/turn.kleen.org.key.pem";
    relay-ips = config.system.publicAddresses;
    extraConfig = ''
      # for debugging
      verbose
      # ban private IP ranges
      no-multicast-peers
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255
      denied-peer-ip=::1
      denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
      denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
      denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
      denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    '';
  };
  systemd.services.coturn = {
    serviceConfig = {
      LoadCredential = [
        "turn.kleen.org.key.pem:${config.security.acme.certs.${config.services.coturn.realm}.directory}/key.pem"
        "turn.kleen.org.pem:${config.security.acme.certs.${config.services.coturn.realm}.directory}/fullchain.pem"
      ];
    };
  };
  age.secrets."coturn-auth" = {
    file = ../../secrets/coturn-auth.age;
    owner = "turnserver";
    group = "turnserver";
  };

  networking.firewall = {
    allowedUDPPorts = [ 3478 5349 ];
    allowedUDPPortRanges = [ { from = config.services.coturn.min-port; to = config.services.coturn.max-port; } ];
    allowedTCPPorts = [ 80 443 8448 3478 5349 ];
  };
}
