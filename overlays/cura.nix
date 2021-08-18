final: prev: {
  cura-x11 = final.symlinkJoin {
    name = "cura";
    paths = [ final.cura ];
    buildInputs = [ final.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/cura --set QT_QPA_PLATFORM xcb
    '';
  };
}
