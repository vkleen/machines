self: pkgs: {
  libspnav  = self.callPackage ./libspnav/libspnav.nix {};
  spacenavd = self.callPackage ./spacenavd/spacenavd.nix {};

  freecad = pkgs.freecad.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ self.libspnav ];
  });
}
