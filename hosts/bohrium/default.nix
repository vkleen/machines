{ lib, buildPlatform, inputs, name, ... }:
let
  trilbyConfig = lib.trilbyConfig {
    inherit name buildPlatform;
    edition = "workstation";
    hostPlatform = "x86_64-linux";
  };
in
rec {
  system = lib.nixosSystem {
    modules = with inputs.self.nixosModules; [
      workstation
      laptop
      profiles.zfs
      profiles.wireshark
      profiles.forst
      profiles.iio
    ] ++ (with (lib.findModules ./.); [
      age
      boot
      filesystems
      interception-tools
      networking
      rmapi
      tweaks
      uucp-email
      wireguard
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
