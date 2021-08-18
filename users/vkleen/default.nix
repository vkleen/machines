{ userName, pkgs, config, lib, ... }:
{
  config = {
    users.users.${userName} = {
      group = "users";
      extraGroups = [ "wheel" ];
      createHome = true;
      home = "/home/${userName}";
      isNormalUser = true;
      shell = "${pkgs.zsh}/bin/zsh";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
      ];
      uid = 1000;
      hashedPassword = "$6$rounds=500000$SmVIMOyBMt$2zWfkdOjlH/OnYQZb/Ix3RUuGl1QGexOyaFuu.KCIuYpw1uhXekpQATgQCkOsKtroxY13eAbiLE8z.cp3jUpo.";
    };
  };
}
