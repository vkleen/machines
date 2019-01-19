{ lib, ... }:
self: super:
{
  packages = pkgs: with pkgs; [
    pkgs.runit
  ];

  overlays = [
    (self: super: {
      runit = lib.statically
                (super.runit.override { static = true; }).overrideAttrs (_: {
                  buildInputs = [];
                });
    })
  ];
}
