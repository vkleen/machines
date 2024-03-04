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
      base
      server
    ]
    ++ lib.findModulesList ./.
    ++ (lib.attrValues (lib.findModules ./accounts));
    #++ (lib.attrValues (lib.findModules ../../accounts));
  };
  output = system.config.system.build;
}

