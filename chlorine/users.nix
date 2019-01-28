{ config, pkgs, ... }:

{
  imports = [ ./secrets.nix ];
  users = {
    mutableUsers = false;
    extraUsers = rec {
      "vkleen" = {
        group = "users";
        extraGroups = [ "wheel" "network" ];
        createHome = true;
        home = "/home/vkleen";
        isNormalUser = true;
        # shell = "${pkgs.zsh}/bin/zsh";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
        ];
        uid = 1000;
        subUidRanges = [
          { count = 1;
            startUid = 1000;
          }
          { count = 65534;
            startUid = 100001;
          }
        ];
        subGidRanges = [
          { count = 1;
            startGid = config.ids.gids.users;
          }
          { count = 999;
            startGid = 1001;
          }
        ];
      };

      "root" = {
        inherit (config.users.extraUsers.vkleen) shell;
        openssh.authorizedKeys.keys = vkleen.openssh.authorizedKeys.keys;
      };
    };
    extraGroups = {
      "network" = { };
    };
  };
}
