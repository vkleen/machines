self: pkgs: {
  libspnav  = self.callPackage ./libspnav/libspnav.nix {};
  spacenavd = self.callPackage ./spacenavd/spacenavd.nix {};
}
