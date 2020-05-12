{ config, pkgs, lib, ... }:
{
  services.openssh.hostKeys = [
    {
      path = "/persist/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
    {
      path = "/persist/ssh/ssh_host_rsa_key";
      type = "rsa";
      bits = 4096;
    }
  ];

  systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /persist/bluetooth"
  ];

  fileSystems."/var/lib/iwd" = {
    device = "/persist/iwd";
    options = [ "bind" ];
  };

  fileSystems."/root/.aws" = {
    device = "/persist/aws";
    options = [ "bind" ];
  };
}
