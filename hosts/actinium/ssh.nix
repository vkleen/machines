{ inputs, lib, ... }:
{
  disabledModules = [ inputs.self.nixosModules.profiles.ssh ];
  config = {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = lib.mkDefault false;
    };

    environment.persistence."/persist".files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key"
    ];

    services.openssh.hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };
}
