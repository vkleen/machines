{config, pkgs, lib, ...}:

with lib;

let
  cfg = config.security.acme;

  dnsOpts = { ... }: {
    options = {
      provider = mkOption {
        type = types.str;
        example = "route53";
        description = ''
          Which DNS provider API to use.
        '';
      };
      environment = mkOption {
        type = types.str;
        example = "route53-acme-creds";
        description = ''
          An environment file in /run/keys/ to be sourced by bash before executing lego.
          Should contain environment variables describing API credentials.
        '';
      };
    };
  };

  certOpts = { name, ... }: {
    options = {
      webroot = mkOption {
        type = types.nullOr types.path;
        example = "/var/lib/acme/acme-challenge";
        description = ''
          Where the webroot of the HTTP vhost is located.
          <filename>.well-known/acme-challenge/</filename> directory
          will be created below the webroot if it doesn't exist.
          <literal>http://example.org/.well-known/acme-challenge/</literal> must also
          be available (notice unencrypted HTTP).
        '';
      };

      domain = mkOption {
        type = types.str;
        default = name;
        description = "Domain to fetch certificate for (defaults to the entry name)";
      };

      email = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Contact email address for the CA to be able to reach you.";
      };

      user = mkOption {
        type = types.str;
        default = "root";
        description = "User running the ACME client.";
      };

      group = mkOption {
        type = types.str;
        default = "root";
        description = "Group running the ACME client.";
      };

      allowKeysForGroup = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Give read permissions to the specified group
          (<option>security.acme.cert.&lt;name&gt;.group</option>) to read SSL private certificates.
        '';
      };

      postRun = mkOption {
        type = types.lines;
        default = "";
        example = "systemctl reload nginx.service";
        description = ''
          Commands to run after new certificates go live. Typically
          the web server and other servers using certificates need to
          be reloaded.

          Executed in the same directory with the new certificate.
        '';
      };

      method = mkOption {
        type = types.enum [ "webroot" "dns" ];
        default = "webroot";
        description = ''
          Which method of verification to use.
        '';
      };

      dns = mkOption {
        type = types.nullOr (types.submodule dnsOpts);
        default = null;
        description = ''
          API paramaters for the dns method.
        '';
      };

      extraDomains = mkOption {
        type = types.attrsOf (types.nullOr types.str);
        default = {};
        example = literalExample ''
          {
            "example.org" = "/srv/http/nginx";
            "mydomain.org" = null;
          }
        '';
        description = ''
          A list of extra domain names, which are included in the one certificate to be issued, with their
          own server roots if needed.
        '';
      };
    };
  };

in

{

  ###### interface

  options = {
    security.acme = {
      directory = mkOption {
        default = "/var/lib/acme";
        type = types.str;
        description = ''
          Directory where certs and other state will be stored by default.
        '';
      };

      validMin = mkOption {
        type = types.int;
        default = 30;
        description = "Minimum remaining validity before renewal in days.";
      };

      renewInterval = mkOption {
        type = types.str;
        default = "weekly";
        description = ''
          Systemd calendar expression when to check for renewal. See
          <citerefentry><refentrytitle>systemd.time</refentrytitle>
          <manvolnum>7</manvolnum></citerefentry>.
        '';
      };

      preliminarySelfsigned = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether a preliminary self-signed certificate should be generated before
          doing ACME requests. This can be useful when certificates are required in
          a webserver, but ACME needs the webserver to make its requests.

          With preliminary self-signed certificate the webserver can be started and
          can later reload the correct ACME certificates.
        '';
      };

      production = mkOption {
        type = types.bool;
        default = true;
        description = ''
          If set to true, use Let's Encrypt's production environment
          instead of the staging environment. The main benefit of the
          staging environment is to get much higher rate limits.

          See
          <literal>https://letsencrypt.org/docs/staging-environment</literal>
          for more detail.
        '';
      };

      certs = mkOption {
        default = { };
        type = with types; attrsOf (submodule certOpts);
        description = ''
          Attribute set of certificates to get signed and renewed.
        '';
        example = literalExample ''
          {
            "example.com" = {
              webroot = "/var/www/challenges/";
              email = "foo@example.com";
              extraDomains = { "www.example.com" = null; "foo.example.com" = "/var/www/foo/"; };
            };
            "bar.example.com" = {
              webroot = "/var/www/challenges/";
              email = "bar@example.com";
            };
          }
        '';
      };
    };
  };

  imports = [ ./keys.nix ];

  ###### implementation
  config = mkMerge [
    (mkIf (cfg.certs != { }) {
      keys = let
          certKeys = listToAttrs (concatLists (mapAttrsToList certToKey cfg.certs));
          certToKey = cert: data: optional (data.method == "dns") (
            nameValuePair "${data.dns.environment}" {}
          );
        in certKeys;

      systemd.services = let
          services = concatLists servicesLists;
          servicesLists = mapAttrsToList certToServices cfg.certs;
          certToServices = cert: data:
              let
                cpath = "${cfg.directory}/${cert}";
                rights = if data.allowKeysForGroup then "750" else "700";
                cmdline = [ "-a" "-d" data.domain ]
                          ++ optionals (data.method == "webroot") [ "--http" "--http.webroot" data.webroot ]
                          ++ optionals (data.method == "dns") [ "--dns" data.dns.provider ]
                          ++ optionals (data.email != null) [ "--email" data.email ]
                          ++ concatLists (mapAttrsToList (name: root: [ "-d" (if root == null then name else "${name}:${root}")]) data.extraDomains)
                          ++ optionals (!cfg.production) ["--server" "https://acme-staging-v02.api.letsencrypt.org/directory"];
                checkGrep = str: "tee >(cat 1>&2) | grep -q '${str}'";
                acmeService = {
                  description = "Renew ACME Certificate for ${cert}";
                  after = [ "network.target" "network-online.target" ]
                    ++ optional (data.method == "dns") "${data.dns.environment}-key.service";
                  wants = [ "network-online.target" ]
                    ++ optional (data.method == "dns") "${data.dns.environment}-key.service";
                  serviceConfig = {
                    Type = "oneshot";
                    PermissionsStartOnly = true;
                    User = data.user;
                    Group = data.group;
                    PrivateTmp = true;
                  };
                  path = with pkgs; [ lego ];
                  preStart = ''
                    mkdir -p '${cfg.directory}'
                    chown 'root:root' '${cfg.directory}'
                    chmod 755 '${cfg.directory}'
                    if [ ! -d '${cpath}' ]; then
                      mkdir '${cpath}'
                    fi
                    chmod ${rights} '${cpath}'
                    chown -R '${data.user}:${data.group}' '${cpath}'
                  '' + optionalString (data.method == "webroot") ''
                    mkdir -p '${data.webroot}/.well-known/acme-challenge'
                    chown -R '${data.user}:${data.group}' '${data.webroot}/.well-known/acme-challenge'
                  '';
                  script = optionalString (data.method == "dns") ''
                    source /run/keys/'${data.dns.environment}'
                  '' + ''
                    cd '${cpath}'
                    set +e
                    if lego list | ${checkGrep "^No certificates"}; then
                      ( lego ${escapeShellArgs cmdline} run | ${checkGrep "Server responded with a certificate.$"} ) \
                        || exit 1
                    else
                      lego ${escapeShellArgs cmdline} renew --days '${toString cfg.validMin}'
                    fi

                    if [[ ! -e '${cpath}'/.lego/certificates/'${cert}'.crt ]]; then
                      printf "certificate '%s' is missing\n" '${cpath}'/.lego/certificates/'${cert}'.crt
                      exit 1
                    fi

                    set -e
                    cp '${cpath}'/.lego/certificates/'${cert}'.key '${cpath}'/key.pem
                    cat '${cpath}'/.lego/certificates/{'${cert}'.crt,'${cert}'.issuer.crt} > '${cpath}'/fullchain.pem
                    cp '${cpath}'/.lego/certificates/'${cert}'.issuer.crt > '${cpath}'/full.pem
                    chown '${data.user}:${data.group}' "${cpath}/"{key,fullchain,full}.pem
                    chmod ${rights} "${cpath}/"{key,fullchain,full}.pem
                  '';
                  postStop = ''
                    cd '${cpath}'
                    ${data.postRun}
                  '';

                  before = [ "acme-certificates.target" ];
                  wantedBy = [ "acme-certificates.target" ];
                };
                selfsignedService = {
                  description = "Create preliminary self-signed certificate for ${cert}";
                  path = [ pkgs.openssl ];
                  preStart = ''
                      if [ ! -d '${cpath}' ]
                      then
                        mkdir -p '${cpath}'
                        chmod ${rights} '${cpath}'
                        chown '${data.user}:${data.group}' '${cpath}'
                      fi
                  '';
                  script =
                    ''
                      workdir="$(mktemp -d)"

                      # Create CA
                      openssl genrsa -des3 -passout pass:xxxx -out $workdir/ca.pass.key 2048
                      openssl rsa -passin pass:xxxx -in $workdir/ca.pass.key -out $workdir/ca.key
                      openssl req -new -key $workdir/ca.key -out $workdir/ca.csr \
                        -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=Security Department/CN=example.com"
                      openssl x509 -req -days 1 -in $workdir/ca.csr -signkey $workdir/ca.key -out $workdir/ca.crt

                      # Create key
                      openssl genrsa -des3 -passout pass:xxxx -out $workdir/server.pass.key 2048
                      openssl rsa -passin pass:xxxx -in $workdir/server.pass.key -out $workdir/server.key
                      openssl req -new -key $workdir/server.key -out $workdir/server.csr \
                        -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=example.com"
                      openssl x509 -req -days 1 -in $workdir/server.csr -CA $workdir/ca.crt \
                        -CAkey $workdir/ca.key -CAserial $workdir/ca.srl -CAcreateserial \
                        -out $workdir/server.crt

                      # Copy key to destination
                      cp $workdir/server.key ${cpath}/key.pem

                      # Create fullchain.pem (same format as "simp_le ... -f fullchain.pem" creates)
                      cat $workdir/{server.crt,ca.crt} > "${cpath}/fullchain.pem"

                      # Create full.pem for e.g. lighttpd
                      cat $workdir/{server.key,server.crt,ca.crt} > "${cpath}/full.pem"

                      # Give key acme permissions
                      chown '${data.user}:${data.group}' "${cpath}/"{key,fullchain,full}.pem
                      chmod ${rights} "${cpath}/"{key,fullchain,full}.pem
                    '';
                  serviceConfig = {
                    Type = "oneshot";
                    PermissionsStartOnly = true;
                    PrivateTmp = true;
                    User = data.user;
                    Group = data.group;
                  };
                  unitConfig = {
                    # Do not create self-signed key when key already exists
                    ConditionPathExists = "!${cpath}/key.pem";
                  };
                  before = [
                    "acme-selfsigned-certificates.target"
                  ];
                  wantedBy = [
                    "acme-selfsigned-certificates.target"
                  ];
                };
              in (
                [ { name = "acme-${cert}"; value = acmeService; } ]
                ++ optional cfg.preliminarySelfsigned { name = "acme-selfsigned-${cert}"; value = selfsignedService; }
              );
          servicesAttr = listToAttrs services;
          injectServiceDep = {
            after = [ "acme-selfsigned-certificates.target" ];
            wants = [ "acme-selfsigned-certificates.target" "acme-certificates.target" ];
          };
        in
          servicesAttr; # //
          # (if config.services.nginx.enable then { nginx = injectServiceDep; } else {}) //
          # (if config.services.lighttpd.enable then { lighttpd = injectServiceDep; } else {});

      systemd.timers = flip mapAttrs' cfg.certs (cert: data: nameValuePair
        ("acme-${cert}")
        ({
          description = "Renew ACME Certificate for ${cert}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = cfg.renewInterval;
            Unit = "acme-${cert}.service";
            Persistent = "yes";
            AccuracySec = "5m";
            RandomizedDelaySec = "1h";
          };
        })
      );

      systemd.targets."acme-selfsigned-certificates" = mkIf cfg.preliminarySelfsigned {};
      systemd.targets."acme-certificates" = {};

      assertions = flip mapAttrsToList cfg.certs (cert: data: {
        assertion = data.method == "webroot" -> data.webroot != null;
        method = "For the webroot method a webroot must be specified for ${cert}";
      });
    })

  ];
}
