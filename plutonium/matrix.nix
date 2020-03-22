{config, pkgs, lib, ...}:
{
  imports = [
    ./secrets.nix
#    ./acme.nix
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

  # services.matrix-synapse = {
  #   enable = true;
  #   server_name = "kleen.org";
  #   public_baseurl = "https://matrix.kleen.org/";
  #   database_type = "sqlite3";

  #   listeners = [
  #     { # federation
  #       bind_address = "127.0.0.1";
  #       port = 8449;
  #       resources = [
  #         { compress = true; names = [ "client" "webclient" ]; }
  #         { compress = false; names = [ "federation" ]; }
  #       ];
  #       tls = false;
  #       type = "http";
  #       x_forwarded = true;
  #     }
  #     { # client
  #       bind_address = "127.0.0.1";
  #       port = 8008;
  #       resources = [
  #         { compress = true; names = [ "client" "webclient" ]; }
  #       ];
  #       tls = false;
  #       type = "http";
  #       x_forwarded = true;
  #     }
  #   ];
  #   extraConfig = ''
  #     max_upload_size: "100M"
  #   '';
  # };

  security.acme.certs = {
    "matrix.kleen.org" = {
      postRun = ''
        systemctl reload nginx.service
      '';
    };
    # "kleen.org" = {
    #   group = "nginx";
    #   user = "nginx";
    #   email = "vkleen-G1v6YSOb@17220103.de";
    #   method = "dns";
    #   dns.provider = "route53";
    #   dns.environment = "route53-acme-creds";
    #   postRun = ''
    #     systemctl reload nginx.service
    #   '';
    # };
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

  # services.nginx = {
  #   enable = true;
  #   virtualHosts."matrix.kleen.org" = {
  #     forceSSL = true;
  #     enableACME = true;
  #     http2 = false;
  #     acmeRoot = "/var/lib/acme/acme-challenge";
  #     locations."/" = {
  #       proxyPass = "http://127.0.0.1:8008";
  #     };
  #   };
  #   virtualHosts."kleen.org" = {
  #     default = true;
  #     onlySSL = true;
  #     http2 = false;
  #     enableACME = false;
  #     listen = [
  #       { addr = "0.0.0.0"; port = 8448; ssl = true; }
  #       { addr = "[::]"; port = 8448; ssl = true; }
  #     ];
  #     locations."/" = {
  #       proxyPass = "http://127.0.0.1:8449";
  #     };
  #     sslCertificate = "/var/lib/acme/kleen.org/fullchain.pem";
  #     sslCertificateKey = "/var/lib/acme/kleen.org/key.pem";
  #     sslTrustedCertificate = "/var/lib/acme/kleen.org/full.pem";
  #   };
  #   recommendedTlsSettings = true;
  # };

  networking.firewall.allowedTCPPorts = [ 80 443 8448 ];
}
