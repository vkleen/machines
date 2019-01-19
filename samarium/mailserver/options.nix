{config, lib, pkgs, ...}:
with lib;
let
  cfg = config.mailserver;
in {
  options.mailserver = {
    enable = mkEnableOption "nixos-mailserver";

    fqdn = mkOption {
      type = types.str;
      example = "mx.example.com";
      description = "The fully qualified domain name of the mail server.";
    };

    domains = mkOption {
      type = types.listOf types.str;
      example = [ "example.com" ];
      default = [];
      description = "The domains that this mail server serves.";
    };

    certificatePath = mkOption {
      type = types.str;
      default = "/var/lib/acme/${cfg.fqdn}/fullchain.pem";
      description = ''
      '';
    };

    keyPath = mkOption {
      type = types.str;
      default = "/var/lib/acme/${cfg.fqdn}/key.pem";
      description = ''
      '';
    };

    messageSizeLimit = mkOption {
      type = types.int;
      example = 52428800;
      default = 20971520;
      description = "Message size limit enforced by Postfix.";
    };

    mailboxSizeLimit = mkOption {
      type = types.int;
      example = 52428800;
      default = 20971520;
      description = "Mailbox size limit enforced by Postfix.";
    };

    virtualAliases = mkOption {
      type = types.attrsOf (types.either (types.listOf types.str) types.str);
      example = {
        "info@example.com" = "user1@example.com";
        "postmaster@example.com" = "user1@example.com";
        "abuse@example.com" = "user1@example.com";
        "multi@example.com" = [ "user1@example.com" "user2@example.com" ];
      };
      description = ''
        Virtual Aliases. A virtual alias `"info@example.com" = "user1@example.com"` means that
        all mail to `info@example.com` is forwarded to `user1@example.com`. Note
        that it is expected that `postmaster@example.com` and `abuse@example.com` is
        forwarded to some valid email address. (Alternatively you can create login
        accounts for `postmaster` and (or) `abuse`). Furthermore, it also allows
        the user `user1@example.com` to send emails as `info@example.com`.
        It's also possible to create an alias for multiple accounts. In this
        example all mails for `multi@example.com` will be forwarded to both
        `user1@example.com` and `user2@example.com`.
      '';
      default = {};
    };

    rejectSender = mkOption {
      type = types.listOf types.str;
      example = [ "@example.com" "spammer@example.net" ];
      description = ''
        Reject emails from these addresses from unauthorized senders.
        Use if a spammer is using the same domain or the same sender over and over.
      '';
      default = [];
    };

    rejectRecipients = mkOption {
      type = types.listOf types.str;
      example = [ "sales@example.com" "info@example.com" ];
      description = ''
        Reject emails addressed to these local addresses from unauthorized senders.
        Use if a spammer has found email addresses in a catchall domain but you do
        not want to disable the catchall.
      '';
      default = [];
    };

    dkimSigning = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to activate dkim signing.
      '';
    };

    dkimSelector = mkOption {
      type = types.str;
      default = "mail";
      description = ''

      '';
    };

    dkimKeyDirectory = mkOption {
      type = types.path;
      default = "/var/dkim";
      description = ''

      '';
    };

    debug = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable verbose logging for mailserver related services. This
        intended be used for development purposes only, you probably don't want
        to enable this unless you're hacking on nixos-mailserver.
      '';
    };

    localDnsResolver = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Runs a local DNS resolver (kresd) as recommended when running rspamd. This prevents your log file from filling up with rspamd_monitored_dns_mon entries.
      '';
    };

    policydSPFExtraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        skip_addresses = 127.0.0.0/8,::ffff:127.0.0.0/104,::1
      '';
      description = ''
        Extra configuration options for policyd-spf. This can be use to among
        other things skip spf checking for some IP addresses.
      '';
    };

    monitoring = {
      enable = mkEnableOption "monitoring via monit";

      alertAddress = mkOption {
        type = types.string;
        description = ''
          The email address to send alerts to.
        '';
      };

      config = mkOption {
        type = types.string;
        default = ''
          set daemon 120 with start delay 60
          set mailserver
              localhost

          set httpd port 2812 and use address localhost
              allow localhost
              allow admin:obwjoawijerfoijsiwfj29jf2f2jd

          check filesystem root with path /
                if space usage > 80% then alert
                if inode usage > 80% then alert

          check system $HOST
                if cpu usage > 95% for 10 cycles then alert
                if memory usage > 75% for 5 cycles then alert
                if swap usage > 20% for 10 cycles then alert
                if loadavg (1min) > 90 for 15 cycles then alert
                if loadavg (5min) > 80 for 10 cycles then alert
                if loadavg (15min) > 70 for 8 cycles then alert

          check process sshd with pidfile /var/run/sshd.pid
                start program  "${pkgs.systemd}/bin/systemctl start sshd"
                stop program  "${pkgs.systemd}/bin/systemctl stop sshd"
                if failed port 22 protocol ssh for 2 cycles then restart

          check process postfix with pidfile /var/lib/postfix/queue/pid/master.pid
                start program = "${pkgs.systemd}/bin/systemctl start postfix"
                stop program = "${pkgs.systemd}/bin/systemctl stop postfix"
                if failed port 25 protocol smtp for 5 cycles then restart
        '';
        description = ''
          The configuration used for monitoring via monit.
          Use a mail address that you actively check and set it via 'set alert ...'.
        '';
      };
    };
  };
}
