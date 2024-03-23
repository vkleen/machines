{ inputs, pkgs, lib, ... }:
{
  users.users.vkleen = {
    group = "users";
    extraGroups = [ "wheel" ];
    createHome = true;
    home = "/home/vkleen";
    isNormalUser = true;
    shell = lib.getExe pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAID4bSfqKF8Hw7SUoA+MEogjSXoqPbmqdud8LfKYbVA6UAAAABHNzaDo= vkleen@bohrium"
    ];
    uid = 1000;
    hashedPassword = "$6$rounds=500000$7e2zTzUzF0Swe72/$MQovOniNUYEy/OO0DZhdnMsuK.dke4A9mVeP2tX1pWU/9vwtZy9H4iYYwcErz4yzSPd0hhVukx24LrudJrX6Y/";
    # hashedPasswordFile = config.age.secrets."vkleen-pass".path;
  };

  home-manager.users.vkleen = lib.mkMerge (with inputs.self.nixosModules.home; [
    server
  ] ++ (with (lib.findModules ./.); [
    {
      home.stateVersion = "24.05";
      manual.manpages.enable = lib.mkForce false;
    }
  ]));
}
