self: super: {
  freecad = super.freecad.overrideAttrs (o: {
    buildInputs = with self; [
      cmake coin3d xercesc ode eigen opencascade-occt gts
      zlib swig gfortran soqt libf2c makeWrapper openmpi vtk hdf5 medfile
      libGLU xorg.libXmu libspnav
    ] ++ (with self.qt5; [
      qtbase qttools qtwebkit qtx11extras
    ]) ++ (with self.python3Packages; [
      matplotlib pycollada shiboken2 pyside2 pyside2-tools pivy python boost
    ]);
  });
}
