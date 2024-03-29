{ flake, lib, config, ... }:
{
  config = lib.mkMerge ([
    {
      services.openssh = {
        enable = true;
        passwordAuthentication = false;
      };
      programs.mosh = {
        enable = true;
        withUtempter = true;
      };

    }
    (lib.mkIf config.boot.wipeRoot {
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
    })
  ]);
}
