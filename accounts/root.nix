{ config, lib, pkgs, ... }:
{
  users.users.root = {
    shell = lib.getExe pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b"
    ];
    initialHashedPassword = lib.mkForce null;
    hashedPasswordFile = config.age.secrets."root-pass".path;
  };

  age.secrets."root-pass" = {
    rekeyFile = ../secrets/root-pass.age;
    owner = "root";
  };
}
