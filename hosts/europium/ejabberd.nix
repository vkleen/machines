{ pkgs, config, lib, ... }:
let
  cfgFile = (pkgs.formats.yaml {}).generate "ejabberd.yaml" {
    hosts = [
      "ejabberd.kleen.org"
    ];
    certfiles = [
      "/run/credentials/ejabberd.service/ejabberd.kleen.org.pem"
      "/run/credentials/ejabberd.service/ejabberd.kleen.org.key.pem"
      "/run/credentials/ejabberd.service/pubsub.xmpp.kleen.org.pem"
      "/run/credentials/ejabberd.service/pubsub.xmpp.kleen.org.key.pem"
      "/run/credentials/ejabberd.service/proxy.xmpp.kleen.org.pem"
      "/run/credentials/ejabberd.service/proxy.xmpp.kleen.org.key.pem"
    ];
    listen = [
      { port = 5222;
        ip = "::";
        module = "ejabberd_c2s";
        starttls = true;
        starttls_required = true;
        max_stanza_size = 262144;
        shaper = "c2s_shaper";
        access = "c2s";
      }
      { port = 5269;
        ip = "::";
        module = "ejabberd_s2s_in";
        max_stanza_size = 524288;
      }
      { port = 5347;
        ip = "10.172.40.1";
        module = "ejabberd_service";
        check_from = "false";
        hosts = {
          "xmpp.kleen.org" = {
            password = "$BIFROST_PASSWORD";
          };
        };
      }
    ];
    s2s_use_starttls = "required";

    auth_method = [ "pam" ];
    pam_service = "xmpp";

    acme = {
      auto = false;
    };

    acl = {
      "local" = {
        user_regexp = "";
      };
      "loopback" = {
        ip = [ "127.0.0.0/8" "::1/128" ];
      };
      "admin" = {
        user = [
          "vkleen@ejabberd.kleen.org"
        ];
      };
    };
    access_rules = {
      "local".allow = "local";
      "c2s" = {
        deny = "blocked";
        allow = "all";
      };
      "announce".allow = "admin";
      "configure".allow = "admin";
      "muc_create".allow = "local";
      "pubsub_createnode".allow = "local";
      "trusted_network".allow = "loopback";
    };
    api_permissions = {
      "console commands" = {
        from = [ "ejabberd_ctl" ];
        who = "all";
        what = "*";
      };
      "admin access" = {
        who = {
          access.allow = [
            { acl = "loopback"; }
            { acl = "admin"; }
          ];
          oauth = {
            scope = "ejabberd:admin";
            access.allow = [
              { acl = "loopback"; }
              { acl = "admin"; }
            ];
          };
        };
        what = [
          "*"
          "!stop" "!start"
        ];
      };
      "public commands" = {
        who = {
          ip = "127.0.0.0/8";
        };
        what = [
          "status" "connected_users_number"
        ];
      };
    };
    shaper = {
      "normal" = {
        rate = 3000;
        burst_size = 20000;
      };
      "fast" = 100000;
    };
    shaper_rules = {
      max_user_sessions = 10;
      max_user_offline_messages = 5000;
      c2s_shaper = {
        "none" = "admin";
        "normal" = "all";
      };
      s2s_shaper = "fast";
    };
    modules = {
      mod_adhoc = {};
      mod_admin_extra = {};
      mod_announce = {
        access = "announce";
      };
      mod_avatar = {};
      mod_blocking = {};
      mod_bosh = {};
      mod_caps = {};
      mod_carboncopy = {};
      mod_client_state = {};
      mod_configure = {};
      mod_disco = {};
      mod_fail2ban = {};
      mod_http_api = {};
      mod_last = {};
      mod_mam = {
        assume_mam_usage = true;
        default = "always";
      };
      mod_mqtt = {};
      mod_muc = {
        access = [ "allow" ];
        access_admin = [
          { "allow" = "admin"; }
        ];
        access_create = "muc_create";
        access_persistent = "muc_create";
        access_mam = [ "allow" ];
        default_room_options = {
          mam = true;
        };
        hosts = [ "muc.xmpp.kleen.org" ];
      };
      mod_offline = {
        access_max_user_messages = "max_user_offline_messages";
      };
      mod_ping = {};
      mod_privacy = {};
      mod_private = {};
      mod_proxy65 = {
        access = "local";
        max_connections = 5;
      };
      mod_pubsub = {
        access_createnode = "pubsub_createnode";
        plugins = [ "flat" "pep" ];
        force_node_config = {
          "storage:bookmarks" = {
            access_model = "whitelist";
          };
        };
      };
      mod_push = {};
      mod_push_keepalive = {};
      mod_register = {
        ip_access = "trusted_network";
      };
      mod_roster = {
        versioning = true;
      };
      mod_s2s_dialback = {};
      mod_shared_roster = {};
      mod_stream_mgmt = {
        resend_on_timeout = "if_offline";
      };
      mod_vcard = {};
      mod_vcard_xupdate = {};
      mod_version = {
        show_os = false;
      };
    };
  };
  
  finalConfigFile = "/var/lib/ejabberd/ejabberd.yaml";

  ectl = let
    cfg = config.services.ejabberd;
    ctlcfg = pkgs.writeText "ejabberdctl.cfg" ''
      ERL_EPMD_ADDRESS=127.0.0.1
      ${cfg.ctlConfig}
    '';
  in ''${cfg.package}/bin/ejabberdctl --config ${cfg.configFile} --ctl-config "${ctlcfg}" --spool "${cfg.spoolDir}" --logs "${cfg.logsDir}"'';
in {
  services.ejabberd = {
    enable = true;
    configFile = finalConfigFile;
    package = pkgs.ejabberd.override { withPam = true; withTools = true; };
  };
  systemd.services.ejabberd = {
    serviceConfig = {
      ExecStart = lib.mkForce ((pkgs.writeShellScript "ejabberd-start" ''
        set -e
        umask 077
        export $(xargs < "''${CREDENTIALS_DIRECTORY}"/config-secrets)
        ${pkgs.envsubst}/bin/envsubst -i "${cfgFile}" > ${finalConfigFile}
        exec ${ectl} foreground
      '').overrideAttrs (_: {
        name = "unit-script-ejabberd";
      }));
      LoadCredential = [
        "ejabberd.kleen.org.key.pem:${config.security.acme.certs."ejabberd.kleen.org".directory}/key.pem"
        "ejabberd.kleen.org.pem:${config.security.acme.certs."ejabberd.kleen.org".directory}/fullchain.pem"
        "pubsub.xmpp.kleen.org.key.pem:${config.security.acme.certs."pubsub.xmpp.kleen.org".directory}/key.pem"
        "pubsub.xmpp.kleen.org.pem:${config.security.acme.certs."pubsub.xmpp.kleen.org".directory}/fullchain.pem"
        "proxy.xmpp.kleen.org.key.pem:${config.security.acme.certs."proxy.xmpp.kleen.org".directory}/key.pem"
        "proxy.xmpp.kleen.org.pem:${config.security.acme.certs."proxy.xmpp.kleen.org".directory}/fullchain.pem"
        "config-secrets:/run/agenix/ejabberd-config-secrets"
      ];
      RuntimeDirectory = "ejabberd";
      RuntimeDirectoryMode = "0700";
    };
  };
  services.nginx.virtualHosts = {
    "ejabberd.kleen.org" = {
      serverName = "ejabberd.kleen.org";
      forceSSL = true;
      enableACME = true;
      http2 = false;
      locations."/".return = "404";
    };
    "pubsub.xmpp.kleen.org" = {
      serverName = "pubsub.xmpp.kleen.org";
      forceSSL = true;
      enableACME = true;
      http2 = false;
      locations."/".return = "404";
    };
    "proxy.xmpp.kleen.org" = {
      serverName = "proxy.xmpp.kleen.org";
      forceSSL = true;
      enableACME = true;
      http2 = false;
      locations."/".return = "404";
    };
  };
  security.pam.services."xmpp".text = ''
    auth requisite pam_succeed_if.so user ingroup xmpp
    auth required pam_unix.so audit likeauth nullok nodelay
    account sufficient pam_unix.so
  '';
  users.groups."shadow" = {
    members = [ "ejabberd"
              ];
  };
  users.groups."xmpp" = {};
  age.secrets."ejabberd-config-secrets".file = ../../secrets/ejabberd-config-secrets.age;

  networking.firewall.allowedTCPPorts = [
    5000 5222 5269
  ];
}
