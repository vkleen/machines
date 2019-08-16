{config, pkgs, lib, ...}:
let
  inherit (lib.strings) concatStringsSep concatMapStringsSep;
  cfg = config.mailserver;

  # extra_valiases_postfix :: [ String ]
  valiases_postfix =
    (map
    (from:
      let to = cfg.virtualAliases.${from};
          aliasList = (l: let aliasStr = builtins.foldl' (x: y: x + y + ", ") "" l;
                          in builtins.substring 0 (builtins.stringLength aliasStr - 2) aliasStr);
      in if (builtins.isList to) then "${from} " + (aliasList to)
                                 else "${from} ${to}")
    (builtins.attrNames cfg.virtualAliases));

  # valiases_file :: Path
  valiases_file = builtins.toFile "valias"
                      (lib.concatStringsSep "\n" valiases_postfix);

  valias_domains = concatStringsSep ", " cfg.domains;

  transport_postfix =    builtins.map (x: "${x} local:") (cfg.domains ++ [ "${cfg.fqdn}" ])
                      ++ [ "seaborgium.kleen.org uucp:seaborgium" ];
  transport_file = builtins.toFile "transport"
                       (lib.concatStringsSep "\n" transport_postfix);

  reject_senders_postfix = (map
    (sender:
      "${sender} REJECT")
    (cfg.rejectSender));
  reject_senders_file = builtins.toFile "reject_senders" (lib.concatStringsSep "\n" (reject_senders_postfix))  ;


  reject_recipients_postfix = (map
    (recipient:
      "${recipient} REJECT")
    (cfg.rejectRecipients));
  # rejectRecipients :: [ Path ]
  reject_recipients_file = builtins.toFile "reject_recipients" (lib.concatStringsSep "\n" (reject_recipients_postfix))  ;

  inetSocket = addr: port: "inet:[${toString port}@${addr}]";
  unixSocket = sock: "unix:${sock}";

  smtpdMilters = (lib.optional cfg.dkimSigning "unix:/run/opendkim/opendkim.sock");

  policyd-spf = pkgs.writeText "policyd-spf.conf" (
    cfg.policydSPFExtraConfig
    + (lib.optionalString cfg.debug ''
    debugLevel = 4
  ''));

  mappedFile = name: "hash:/var/lib/postfix/conf/${name}";
in
{
  imports = [
    ./uucp.nix
  ];
  config = with cfg; lib.mkIf enable {
    services.uucp = {
      enable = true;
      nodeName = config.networking.hostName;
      remoteNodes = [ "amy" "seaborgium" ];
      sshUser = {
        openssh.authorizedKeys.keys = [
          ''
          no-port-forwarding,no-X11-forwarding,no-agent-forwarding,command="${pkgs.uucp}/bin/uucico" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzPd3YvC0XZoH1QtPYkBTUUO0+lJCnM6Ey947rDoka7 root@seaborgium
          ''
        ];
      };
    };

    services.postfix = {
      enable = true;
      hostname = "${fqdn}";
      networksStyle = "host";
      mapFiles."valias" = valiases_file;
      mapFiles."transport" = transport_file;
      mapFiles."reject_senders" = reject_senders_file;
      mapFiles."reject_recipients" = reject_recipients_file;
      sslCert = certificatePath;
      sslKey = keyPath;
      enableSubmission = false;

      recipientDelimiter = "+-";

      destination = [ "localhost" "${fqdn}" ];

      extraConfig =
      ''
        # Extra Config
        smtpd_banner = ${fqdn} ESMTP NO UCE
        disable_vrfy_command = yes
        message_size_limit = ${builtins.toString cfg.messageSizeLimit}
        mailbox_size_limit = ${builtins.toString cfg.mailboxSizeLimit}

        # virtual mail system
        virtual_alias_domains = ${valias_domains}
        virtual_alias_maps = ${mappedFile "valias"}

        transport_maps = ${mappedFile "transport"}

        smtpd_relay_restrictions = permit_mynetworks, reject_unauth_destination

        policy-spf_time_limit = 3600s

        # reject selected senders
        smtpd_sender_restrictions = check_sender_access ${mappedFile "reject_senders"}

        # quota and spf checking
        smtpd_recipient_restrictions =
          check_recipient_access ${mappedFile "reject_recipients"},
          check_policy_service unix:private/policy-spf

        # TLS settings, inspired by https://github.com/jeaye/nix-files
        # Submission by mail clients is handled in submissionOptions
        smtpd_tls_security_level = may
        # strong might suffice and is computationally less expensive
        smtpd_tls_eecdh_grade = ultra
        # Disable predecessors to TLS
        smtpd_tls_protocols = !SSLv2, !SSLv3
        # Allowing AUTH on a non encrypted connection poses a security risk
        smtpd_tls_auth_only = yes
        # Log only a summary message on TLS handshake completion
        smtpd_tls_loglevel = 1

        # Disable weak ciphers as reported by https://ssl-tools.net
        # https://serverfault.com/questions/744168/how-to-disable-rc4-on-postfix
        smtpd_tls_exclude_ciphers = RC4, aNULL
        smtp_tls_exclude_ciphers = RC4, aNULL

        # Configure a non blocking source of randomness
        tls_random_source = dev:/dev/urandom

        smtpd_milters = ${lib.concatStringsSep "," smtpdMilters}
        ${lib.optionalString cfg.dkimSigning "non_smtpd_milters = unix:/run/opendkim/opendkim.sock"}
        milter_protocol = 6
        milter_mail_macros = i {mail_addr} {client_addr} {client_name} {auth_type} {auth_authen} {auth_author} {mail_addr} {mail_host} {mail_mailer}
      '';

      masterConfig = {
        "policy-spf" = {
          type = "unix";
          privileged = true;
          chroot = false;
          command = "spawn";
          args = [ "user=nobody" "argv=${pkgs.pypolicyd-spf}/bin/policyd-spf" "${policyd-spf}"];
        };

        "uucp" = {
          type = "unix";
          privileged = true;
          chroot = false;
          maxproc = 100;
          command = "pipe flags=Fqhu user=uucp argv=/run/wrappers/bin/uux -r -n -z -a $sender - $nexthop!rmail ($recipient)";
        };
      };
    };
  };
}
