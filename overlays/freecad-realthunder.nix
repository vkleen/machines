final: prev: let
  py_slvs = final.python3Packages.buildPythonPackage rec {
    pname = "py-slvs";
    version = "1.0.1";
    src = final.fetchFromGitHub {
      owner = "realthunder";
      repo = "slvs_py";
      rev = "ba17e8c1015554812acf73ac8fdab9ebd8e15653";
      fetchSubmodules = true;
      sha256 = "sha256-YbBFYOunAdV2nUa8RtnkjonCFXKvnnAZsnkyOvI0cVA=";
    };

    nativeBuildInputs = with final; with final.python3Packages; [ cmake swig scikit-build setuptools ];
    dontUseCmakeConfigure = true;
    doCheck = false;
  };

in prev.lib.onlySystems prev.lib.supportedSystems {
  freecad-realthunder = prev.freecad.overrideAttrs (o: {
    version = "realthunder";
    src = final.freecad-src;
    postInstall = (o.postInstall or "") + ''
      cp -Rv ${final.freecad-assembly3-src} $out/Mod/asm3
    '';
    buildInputs = o.buildInputs ++ [ final.libspnav py_slvs ];
  });

  freecad-realthunder-x11 = final.symlinkJoin {
    name = "freecad";
    paths = [ final.freecad-realthunder ];
    buildInputs = [ final.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/freecad --set QT_QPA_PLATFORM xcb
      wrapProgram $out/bin/FreeCAD --set QT_QPA_PLATFORM xcb
    '';
  };
}
