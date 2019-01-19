{ lib, buildPackages, ... }:
self: super:
{
  overlays = [
    (self : super: {
      argp-standalone = self.callPackage ../coreboot/argp-standalone.nix {};
      coreboot = buildPackages.callPackage ../coreboot {
        configfile = ../coreboot/config/config.librem13v3;
        inherit lib;
      };
    })
  ];
}
