{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    inputs.self.nixosModules.uucp
  ];
  options = {
    uucp-email.secretFile = lib.mkOption { type = lib.types.path; };
    uucp-email.upstream.name = lib.mkOption { type = lib.types.str; };
    uucp-email.upstream.host = lib.mkOption { type = lib.types.str; };
    uucp-email.upstream.sshKey = lib.mkOption { type = lib.types.str; };
  };
  config = {
    services = {
      uucp = {
        enable = true;
        nodeName = config.networking.hostName;
        remoteNodes = [ config.uucp-email.upstream.name ];
        sshConfig = ''
          Host ${config.uucp-email.upstream.name}
            Hostname ${config.uucp-email.upstream.host}
            IdentityFile ${config.age.secrets.uucp.path}
        '';
        sshHosts = ''
          ${config.uucp-email.upstream.name} ${config.uucp-email.upstream.sshKey}
        '';
        interval = "10min";
      };

      postfix =
        let
          cfg = config;
        in
        rec {
          enable = true;
          enableSmtp = false;
          setSendmail = true;
          networksStyle = "host";
          hostname = "${cfg.networking.hostName}.kleen.org";
          destination = [ "${cfg.networking.hostName}.kleen.org" "localhost" ];
          relayDomains = destination;
          recipientDelimiter = "+-";
          transport = ''
            ${cfg.networking.hostName}.kleen.org :
            *                    uucp:${cfg.uucp-email.upstream.name}
          '';

          masterConfig = {
            uucp = {
              name = "uucp";
              type = "unix";
              privileged = true;
              chroot = false;
              maxproc = 100;
              command = "pipe flags=Fqhu user=uucp argv=${cfg.security.wrapperDir}/uux -z -a $sender - $nexthop!rmail ($recipient)";
            };
          };

          config = {
            mailbox_size_limit = "8192000000";
            message_size_limit = "2048000000";
          };
        };
    };
    age.secrets."uucp" = {
      rekeyFile = config.uucp-email.secretFile;
      owner = "uucp";
    };
  };
}
