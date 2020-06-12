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
    database_type = "sqlite3";
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
        listen = [
          { addr = "0.0.0.0"; port = 8448; ssl = true; }
          { addr = "[::]"; port = 8448; ssl = true; }
          { addr = "0.0.0.0"; port = 443; ssl = true; }
          { addr = "[::]"; port = 443; ssl = true; }
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 8448 ];
}
