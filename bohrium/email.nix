{ config, pkgs, ... }:

{
  imports =
    [ ./custom/uucp.nix
    ];

  services = {
    uucp = {
      enable = true;
      nodeName = config.networking.hostName;
      remoteNodes = [ "amy" "samarium" ];
      sshConfig = ''
        Host amy
          Hostname ssh.17220103.de
          IdentityFile ~/.ssh/uucp_ed25519

        Host samarium
          Hostname samarium.17220103.de
          IdentityFile ~/.ssh/uucp_ed25519
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
          command = "pipe flags=Fqhu user=uucp argv=/run/wrappers/bin/uux -z -a $sender - $nexthop!rmail ($recipient)";
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
