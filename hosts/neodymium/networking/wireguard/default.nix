{ config, inputs, ... }:
{
  imports = [ inputs.self.nixosModules.profiles.wireguard ];
  config = {
    wolkenheim.wireguard = {
      enable = true;
      public = builtins.readFile ./public;
      private = ./private.age;
    };
    networking.wireguard.interfaces = {
      bohrium = {
        ips = [ "10.172.50.1/24" ];
        privateKeyFile = config.age.secrets.wolkenheim-wireguard.path;
        listenPort = 51820;
        peers = [
          {
            publicKey = inputs.self.utils.wireguard.bohrium.public;
            allowedIPs = [ "10.172.50.132/32" ];
          }
          # {
          #   publicKey = builtins.readFile ../../wireguard/helium.pub;
          #   allowedIPs = [ "10.172.50.133/32" ];
          # }
          # {
          #   publicKey = builtins.readFile ../../wireguard/boron.pub;
          #   allowedIPs = [ "10.172.50.136/32" ];
          # }
        ];
      };
    };
  };
}
