{ flake, config, pkgs, ... }:

let cfg = config;
in {
  imports =
    [ flake.nixosModules.uucp
    ];

  services = {
    uucp = {
      enable = true;
      nodeName = cfg.networking.hostName;
      remoteNodes = [ "samarium" ];
      sshConfig = ''
        Host samarium
          Hostname 10.172.20.1
          IdentityFile /persist/uucp_ed25519
      '';
      sshHosts = ''
        samarium ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ4wuOpHO+UmLG+D5xEQadJaeR5lm7FKmt22a2uysOYE
      '';
      interval = "10min";
    };

    postfix = rec {
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
        *                    uucp:samarium
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
}
