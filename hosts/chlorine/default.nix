{ mkNixosConfig, lib, inputs, ... }:
mkNixosConfig {
  hostName = "chlorine";
  hostPlatform = "powerpc64le-linux";
  modules = [
    {
      system.macnameNamespace = "auenheim.kleen.org";
      system.stateVersion = "23.05";
    }
    ./hardware.nix
    ./networking.nix
    ({ pkgs, ... }: {
      users.users.root = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAID4bSfqKF8Hw7SUoA+MEogjSXoqPbmqdud8LfKYbVA6UAAAABHNzaDo= vkleen@bohrium"
        ];
        hashedPassword = "$6$rounds=500000$LOTAq.HWQYxy$lKdVbv3O7kER44KRcmVL6q5Ahvwi78CfLNVElX/KwXuqXsAu6L9NQ98Y2BWbkI9fHyuqr8lBfD30BTgikLhB20";
      };
      users.users.vkleen = {
        group = "users";
        extraGroups = [ "wheel" ];
        createHome = true;
        home = "/home/vkleen";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP03cNnW4bB4rqxfp62V1SqskfI9Gja0+EApP9//tz+b vkleen@arbro"
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAID4bSfqKF8Hw7SUoA+MEogjSXoqPbmqdud8LfKYbVA6UAAAABHNzaDo= vkleen@bohrium"
        ];
        uid = 1000;
        hashedPassword = "$6$rounds=500000$SmVIMOyBMt$2zWfkdOjlH/OnYQZb/Ix3RUuGl1QGexOyaFuu.KCIuYpw1uhXekpQATgQCkOsKtroxY13eAbiLE8z.cp3jUpo.";
      };
    })
    {
      boot.supportedFilesystems = [ "zfs" ];
      boot.zfs = {
        enableUnstable = true;
        forceImportRoot = false;
        forceImportAll = false;
      };
    }
  ] ++ lib.attrValues {
    inherit (inputs.self.nixosModules)
      core;
    inherit (inputs.self.nixosModules.profiles)
      chrony
      doas
      latest-linux
      nix
      ssh
      ;
  };
}
