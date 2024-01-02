{ lib, config, inputs, ... }:
{
  imports = with inputs.self.nixosModules; [
    trilby.profiles.ssh
  ];
  config = lib.mkIf (config.boot.wipeRoot or false) {
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
  };
}
