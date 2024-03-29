{ flake, config, pkgs, ... }: let
  cfgFile = (pkgs.formats.yaml {}).generate "bifrost.yaml" {
    bridge = {
      domain = "kleen.org";
      homeserverUrl = "https://matrix.kleen.org";
      userPrefix = "_bifrost_";
      mediaserverUrl = "https://matrix.kleen.org";
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
        service = "xmpp://10.172.40.1:5347";
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
      requires = [ "wireguard-wg-europium.service" ];
      after = [ "wireguard-wg-europium.service" ];
      description = "matrix-bifrost bridge";
      script = let
        bifrost = flake.inputs.matrix-bifrost.defaultPackage.${config.nixpkgs.system};
      in ''
        umask 077
        export $(xargs < "''${CREDENTIALS_DIRECTORY}"/config-secrets)
        ${pkgs.envsubst}/bin/envsubst -i "${cfgFile}" > ${finalConfigFile}
        mkdir -p "''${STATE_DIRECTORY}"/config
        cp ${bifrost}/config/config.schema.yaml "''${STATE_DIRECTORY}"/config/
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
        ];
      };
    };
    age.secrets."bifrost-config-secrets".file = ../../secrets/ejabberd-config-secrets.age;
    age.secrets."bifrost-registration".file = ../../secrets/bifrost-registration.age;

    users.users.bifrost = {
      group = "bifrost";
      home = "/var/lib/matrix-bifrost";
      isSystemUser = true;
    };
    users.groups.bifrost = {};

    networking.firewall.interfaces."wg-europium".allowedTCPPorts = [ 9555 ];
    networking.firewall.interfaces."neodymium".allowedTCPPorts = [ 9555 ];

    fileSystems."/var/lib/matrix-bifrost" = {
      device = "/persist/matrix-bifrost";
      options = [ "bind" ];
    };
  };
}
