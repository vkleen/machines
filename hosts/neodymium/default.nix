{ lib, buildPlatform, inputs, name, ... }:
let
  trilbyConfig = lib.trilbyConfig {
    inherit name buildPlatform;
    edition = "server";
    hostPlatform = "x86_64-linux";
  };
in
rec {
  system = lib.nixosSystem trilbyConfig {
    modules = with inputs.self.nixosModules; [
      server
      profiles.mailserver
      profiles.wolkenheim
    ]
    ++ lib.findModulesList ./.
    ++ lib.findModulesList ../../accounts;
  };
  output = system.config.system.build.toplevel;
}
