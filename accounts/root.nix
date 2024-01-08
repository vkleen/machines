{ config, lib, pkgs, ... }:
{
  users.users.root = {
    shell = lib.getExe pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAID4bSfqKF8Hw7SUoA+MEogjSXoqPbmqdud8LfKYbVA6UAAAABHNzaDo= vkleen@bohrium"
    ];
    hashedPasswordFile = config.age.secrets."root-pass".path;
  };

  age.secrets."root-pass" = {
    rekeyFile = ../secrets/root-pass.age;
    owner = "root";
  };
}
