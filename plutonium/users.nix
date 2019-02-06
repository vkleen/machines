{ config, pkgs, ... }:

{
  users = {
    mutableUsers = false;
    extraUsers = rec {
      "vkleen" = {
        hashedPassword = "$6$rounds=500000$SmVIMOyBMt$2zWfkdOjlH/OnYQZb/Ix3RUuGl1QGexOyaFuu.KCIuYpw1uhXekpQATgQCkOsKtroxY13eAbiLE8z.cp3jUpo.";
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
        hashedPassword = "$6$rounds=500000$LOTAq.HWQYxy$lKdVbv3O7kER44KRcmVL6q5Ahvwi78CfLNVElX/KwXuqXsAu6L9NQ98Y2BWbkI9fHyuqr8lBfD30BTgikLhB20";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
        ];
      };
    };
  };
}
