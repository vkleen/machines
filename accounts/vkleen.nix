{ config, pkgs, lib, ... }:
{
  users.users.vkleen = {
    group = "users";
    extraGroups = [ "wheel" ];
    createHome = true;
    home = "/home/vkleen";
    isNormalUser = true;
    shell = lib.getExe pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b"
    ];
    uid = 1000;
    hashedPasswordFile = config.age.secrets."vkleen-pass".path;
  };

  age.secrets."vkleen-pass" = {
    rekeyFile = ../secrets/vkleen-pass.age;
    owner = "root";
  };
}
