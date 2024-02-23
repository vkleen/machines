{ config, inputs, trilby, ... }:
let
  inherit (inputs.self.utils.nix) getPrimaryPublicV4;
  inherit (inputs.self.utils) wireguard;
in
{
  imports = [ inputs.self.nixosModules.profiles.wireguard ];
  config = {
    wolkenheim.wireguard = {
      enable = true;
      public = builtins.readFile ./public;
      private = ./private.age;
    };
    networking.wireguard.interfaces = {
      neodymium = {
        ips = [ "10.172.50.132/24" ];
        privateKeyFile = config.age.secrets.wolkenheim-wireguard.path;
        allowedIPsAsRoutes = false;
        peers = [
          {
            publicKey = wireguard.neodymium.public;
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "${getPrimaryPublicV4 "neodymium"}:${builtins.toString wireguard.neodymium.links.${trilby.name}.listenPort}";
          }
        ];
      };
    };
  };
}
