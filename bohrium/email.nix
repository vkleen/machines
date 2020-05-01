{ config, pkgs, ... }:

let cfg = config;
in {
  imports =
    [ ./custom/uucp.nix
    ];

  services = {
    uucp = {
      enable = true;
      nodeName = cfg.networking.hostName;
      remoteNodes = [ "amy" "samarium" ];
      sshConfig = ''
        Host amy
          Hostname ssh.17220103.de
          IdentityFile /persist/uucp_ed25519

        Host samarium
          Hostname samarium.17220103.de
          IdentityFile /persist/uucp_ed25519
      '';
      sshHosts = ''
        amy ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDN4cPeBWV6dynzj8EvFfky3ABK3DBdSvfKyXZcnjFY
        samarium ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ4wuOpHO+UmLG+D5xEQadJaeR5lm7FKmt22a2uysOYE
      '';
      interval = "10min";
    };

    postfix = rec {
      enable = true;
      enableSmtp = false;
      setSendmail = true;
      networksStyle = "host";
      hostname = "bohrium.kleen.org";
      destination = [ "bohrium.kleen.org" "localhost" ];
      relayDomains = destination;
      recipientDelimiter = "+-";
      transport = ''
        bohrium.kleen.org :
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

  environment.systemPackages = with pkgs; [
    procmail
  ];
}
