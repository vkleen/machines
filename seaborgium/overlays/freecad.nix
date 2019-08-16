self: super: {
  freecad = self.qt5.callPackage ./freecad/freecad.nix { mpi = self.openmpi; };
}
