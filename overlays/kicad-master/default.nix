final: prev: let
  wxGTK = final.wxGTK31.override {
    withGtk2 = false;
    withWebKit = true;
  };
  wxPython = (final.python3.pkgs.wxPython_4_1.override { inherit wxGTK; }).overrideAttrs (o: {
    patches = o.patches or [] ++ [
      ./fix-wxpython-4.1.1-on-wxwidgets-3.1.5.patch
    ];
    nativeBuildInputs = o.nativeBuildInputs ++ [
      wxGTK
    ];
    buildInputs = o.buildInputs ++ [
      wxGTK
    ];
    buildPhase = ''
      ${final.python3.interpreter} build.py -v build_wx dox etg --use_syswx --nodoc sip build_py
    '';
  });
in {
  kicad-master = prev.kicad-unstable.override {
    srcs = {
      kicadVersion = "master";
      kicad = final.kicad-src;
    };
    stable = false;
    doCheck = false;
    wxGTK31-gtk3 = wxGTK;
    inherit (final) python3;
    inherit wxPython;
  };

  kikit = with final.python3Packages; toPythonApplication kikit;

  python3 = prev.python3.override (old: {
    packageOverrides = final.lib.composeExtensions (old.packageOverrides or (_: _: {})) (pself: _: {
      kikit = pself.callPackage ./kikit.nix {
        kicad = final.kicad-master.base;
        inherit wxPython;
      };
    });
  });
}
