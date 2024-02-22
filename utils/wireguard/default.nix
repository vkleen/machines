{ inputs, lib, ... }:
{
  keys = lib.foreach inputs.self.nixosConfigurations (n: system:
    {
      ${n} = lib.optionalAttrs (system.config.wolkenheim.wireguard.enable or false) {
        public = system.config.wolkenheim.wireguard.public;
        private = system.config.wolkenheim.wireguard.private;
      };
    });
}
