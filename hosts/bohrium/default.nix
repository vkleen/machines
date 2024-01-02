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
      profiles.zfs
      profiles.wipe-root
      profiles.wireshark
      profiles.forst
    ] ++ (with (lib.findModules ./.); [
      age
      tweaks
      interception-tools
      uucp-email
      boot
      filesystems
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
