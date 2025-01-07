{ inputs, config, pkgs, ... }: let
  cfgFile = (pkgs.formats.json {}).generate "bifrost.yaml" {
    bridge = {
      domain = "kleen.org";
      homeserverUrl = "http://localhost:8008";
      userPrefix = "_bifrost_";
      mediaProxy = {
        signingKeyPath = "$CREDENTIALS_DIRECTORY/media-bridge-signing.jwk";
        ttlSeconds = 3600;
        bindPort = 11111;
        publicUrl = "https://bifrost.xmpp.kleen.org/media";
      };
      appservicePort = 9555;
    };
    roomRules = [];
    datastore = {
      engine = "nedb";
      connectionString = "/var/lib/matrix-bifrost";
    };
    purple = {
      backend = "xmpp-js";
      backendOpts = {
        service = "xmpp://127.0.0.1:5347";
        domain = "xmpp.kleen.org";
        password = "$BIFROST_PASSWORD";
      };
    };
    portals = {
      enableGateway = false;
      aliases = {
        "/^_bifrost_(.+)$/" = {
          protocol = "xmpp-js";
          properties = {
            room = "regex:1";
            server = "regex:2";
          };
        };
      };
    };
    autoRegistration = {
      enabled = true;
      protocolSteps = {
        xmpp-js = {
          type = "static";
          parameters = {
            "@viktor:kleen.org" = "vkleen@xmpp.kleen.org";
          };
        };
      };
    };
    access = {
      accountCreation = {
        whitelist = [
          "^@viktor:kleen.org$"
        ];
      };
    };
    metrics = {
      enabled = true;
    };
    provisioning = {
      enablePlumbing = true;
      requiredUserPL = 100;
    };
    logging = {
      console = "info";
      files = {};
    };
    tuning = {
      waitOnProfileBeforeSend = true;
    };
  };
  finalConfigFile = "/var/lib/matrix-bifrost/bifrost.yaml";
in {
  config = {
    systemd.services.matrix-bifrost = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "matrix-synapse.service" ];
      after = [ "matrix-synapse.service" ];
      description = "matrix-bifrost bridge";
      script = let
        bifrost = inputs.matrix-bifrost.defaultPackage.${pkgs.stdenv.hostPlatform.system};
      in ''
        umask 077
        export $(xargs < "''${CREDENTIALS_DIRECTORY}"/config-secrets)
        ${pkgs.envsubst}/bin/envsubst -i "${cfgFile}" > ${finalConfigFile}
        sha256sum "''${CREDENTIALS_DIRECTORY}/media-bridge-signing.jwk"
        mkdir -p "''${STATE_DIRECTORY}"/config
        cp ${inputs.matrix-bifrost}/config/config.schema.yaml "''${STATE_DIRECTORY}"/config/
        exec ${bifrost}/bin/matrix-bifrost -f "''${CREDENTIALS_DIRECTORY}"/bifrost-registration.yaml -c ${finalConfigFile} -p 9555
      '';
      serviceConfig = {
        RestartSec = "5s";
        Restart = "always";
        WorkingDirectory = "/var/lib/matrix-bifrost";
        StateDirectoryMode = "0700";
        StateDirectory = "matrix-bifrost";
        User = "bifrost";
        Group = "bifrost";
        DynamicUser = false;
        LoadCredential = [
          "config-secrets:/run/agenix/bifrost-config-secrets"
          "bifrost-registration.yaml:/run/agenix/bifrost-registration"
          "media-bridge-signing.jwk:/run/agenix/media-bridge-signing.jwk"
        ];
      };
    };
    age.secrets."bifrost-config-secrets".file = ../ejabberd/ejabberd-config-secrets.age;
    age.secrets."bifrost-registration".file = ./bifrost-registration.age;
    age.secrets."media-bridge-signing.jwk".file = ./media-bridge-signing.age;

    users.users.bifrost = {
      group = "bifrost";
      home = "/var/lib/matrix-bifrost";
      isSystemUser = true;
    };
    users.groups.bifrost = {};
  };
}
