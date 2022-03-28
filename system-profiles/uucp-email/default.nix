{ flake, config, pkgs, ... }:

let cfg = config;
in {
  services = {
    uucp = {
      enable = true;
      nodeName = cfg.networking.hostName;
      remoteNodes = [ "samarium" "neodymium" ];
      sshConfig = ''
        Host samarium
          Hostname samarium.kleen.org
          IdentityFile /run/agenix/uucp/id_ed25519
        Host neodymium
          Hostname neodymium.kleen.org
          IdentityFile /run/agenix/uucp/id_ed25519
      '';
      sshHosts = ''
        samarium ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ4wuOpHO+UmLG+D5xEQadJaeR5lm7FKmt22a2uysOYE
        neodymium ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/rujrnskTy66GPBnKnWbwf45I7pWEjcXyaQoVHgDG8
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
        *                    uucp:neodymium
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
  age.secrets."uucp/id_ed25519" = {
    file = ../../secrets/uucp/id_ed25519.age;
    owner = "uucp";
  };
}
