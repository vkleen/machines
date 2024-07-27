{ lib, buildPlatform, inputs, name, ... }:
let
  trilbyConfig = lib.trilbyConfig {
    inherit name buildPlatform;
    edition = "workstation";
    hostPlatform = "x86_64-linux";
  };
in
rec {
  system = lib.nixosSystem trilbyConfig {
    modules = with inputs.self.nixosModules; [
      workstation
      laptop
      profiles.zfs
      profiles.wireshark
      profiles.forst
      profiles.iio
    ]
    ++ lib.findModulesList ./.
    ++ (lib.attrValues (lib.findModules ../../accounts))
    ++ (lib.attrValues (lib.findModules ./accounts));
  };
  output = system.config.system.build.toplevel;
}
