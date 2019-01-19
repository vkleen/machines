{ lib, ... }:
self: super:
{
  packages = pkgs: with pkgs; [
    pkgs.dropbear
  ];
  overlays = [
    (self: super: {
      dropbear = super.dropbear.overrideAttrs (o: {
        configureFlags = [ "LDFLAGS=-static" ];
        buildInputs = [ self.zlibStatic self.zlibStatic.static ];
      });
    })
  ];
}
