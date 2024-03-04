{ lib, buildPlatform, inputs, name, ... }:
let
  trilbyConfig = lib.trilbyConfig {
    inherit name buildPlatform;
    edition = "workstation";
    hostPlatform = "powerpc64le-linux";
  };
in
rec {
  system = lib.nixosSystem trilbyConfig {
    modules = with inputs.self.nixosModules; [
      workstation
      profiles.zfs
      profiles.wireshark
      profiles.iio
    ] ++ (with (lib.findModules ./.); [
      age
      boot
      filesystems
      networking
      tweaks
      uinput
    ])
    ++ (lib.attrValues (lib.findModules ../../accounts))
    ++ (lib.attrValues (lib.findModules ./accounts));
  };
  output = system.config.system.build.toplevel;
}
