{ lib, ... }:
self: super:
{
  packages = pkgs: with pkgs; [
    pkgs.monit
  ];

  overlays = [
    (self: super: {
      monit = (lib.statically (super.monit.override {
                                zlib = self.zlibStatic;
                                usePAM = false; useSSL = false; })).overrideAttrs (o: {
                buildInputs = o.buildInputs ++ [ self.zlibStatic.static ];
              });
    })
  ];
}
