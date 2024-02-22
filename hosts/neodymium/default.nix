{ lib, buildPlatform, inputs, name, ... }:
let
  trilbyConfig = lib.trilbyConfig {
    inherit name buildPlatform;
    edition = "server";
    hostPlatform = "x86_64-linux";
  };
in
rec {
  system = lib.nixosSystem {
    modules = with inputs.self.nixosModules; [
      server
      profiles.wolkenheim
    ] ++ (with (lib.findModules ./.); [
      age
      boot
      filesystems
      networking
    ])
    ++ (lib.attrValues (lib.findModules ../../accounts));
    specialArgs.trilby = trilbyConfig;
  };
  output = system.config.system.build.toplevel;
}
