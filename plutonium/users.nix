{ config, pkgs, ... }:

{
  users = {
    mutableUsers = false;
    extraUsers = rec {
      "vkleen" = {
        group = "users";
        extraGroups = [ "wheel" ];
        createHome = true;
        home = "/home/vkleen";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
        ];
        uid = 1000;
      };

      "root" = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
        ];
      };
    };
  };
}
