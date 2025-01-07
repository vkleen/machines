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
      profiles.wireshark
      profiles.iio
      profiles.virtualisation
    ]
    ++ lib.findModulesList ./.
    ++ (lib.findModulesList ./accounts)
    ++ (lib.attrValues (lib.findModules ../../accounts));
  };
  output = system.pkgs.linkFarm "uranium" [
    {
      name = "nixos.efi";
      path = "${system.config.system.build.uki}/nixos.efi";
    }
    {
      name = "toplevel";
      path = "${system.config.system.build.toplevel}";
    }
  ];
}

