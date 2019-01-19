{ lib, ... }:
self: super:
{
  packages = pkgs: with pkgs; [
    pkgs.busybox
  ];

  overlays = [
    (self : super: {
      busybox = lib.statically (super.busybox.override {
        enableMinimal = false;
      }).overrideAttrs (_: {
        postConfigure = "true";
      });
    })
  ];
}
