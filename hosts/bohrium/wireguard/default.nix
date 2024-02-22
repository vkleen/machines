{ inputs, ... }:
{
  imports = [ inputs.self.nixosModules.profiles.wireguard ];
  config = {
    wolkenheim.wireguard = {
      enable = true;
      public = builtins.readFile ./public;
      private = ./private.age;
    };
  };
}
