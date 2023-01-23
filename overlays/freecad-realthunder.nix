final: prev: let
  py_slvs = final.python3Packages.buildPythonPackage rec {
    pname = "py-slvs";
    version = "1.0.3";
    src = final.fetchFromGitHub {
      owner = "realthunder";
      repo = "slvs_py";
      rev = "c94979b0204a63f26683c45ede1136a2a99cb365";
      fetchSubmodules = true;
      sha256 = "sha256-bOdTmSMAA0QIRlcIQHkrnDH2jGjGJqs2i5Xaxu2STMU=";
    };

    nativeBuildInputs = with final; with final.python3Packages; [ cmake swig scikit-build setuptools ];
    dontUseCmakeConfigure = true;
    doCheck = false;
  };

in prev.lib.onlySystems prev.lib.supportedSystems {
  inherit py_slvs;
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
