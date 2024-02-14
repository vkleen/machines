{ lib, buildPlatform, inputs, name, ... }:
let
  trilbyConfig = lib.trilbyConfig {
    inherit name buildPlatform;
    edition = "workstation";
    hostPlatform = "powerpc64le-linux";
  };
in
rec {
  system = lib.nixosSystem {
    modules = with inputs.self.nixosModules; [
      workstation
      profiles.zfs
      profiles.wireshark
      profiles.iio
    ] ++ (with (lib.findModules ./.); [
      age
      filesystems
      tweaks
    ])
    ++ (lib.attrValues (lib.findModules ../../accounts))
    ++ (lib.attrValues (lib.findModules ./accounts));
    specialArgs = {
      inherit inputs lib;
      trilby = trilbyConfig;
    };
  };
  output = system.config.system.build.toplevel;
}
