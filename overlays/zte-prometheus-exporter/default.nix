final: prev:
let
  packageOverrides = final.callPackage ./python-packages.nix {};
  inpPython = final.python310.override { inherit packageOverrides; };
in {
  zte-prometheus-exporter = prev.stdenv.mkDerivation rec {
    name = "zte-prometheus-exporter";
    src = ./zte-prometheus-exporter.py;

    phases = [ "buildPhase" "checkPhase" "installPhase" ];

    python = inpPython.withPackages (ps: with ps; [pytimeparse requests]);

    buildPhase = ''
      substituteAll $src zte-prometheus-exporter
    '';

    doCheck = true;
    checkPhase = ''
      ${python}/bin/python -m py_compile zte-prometheus-exporter
    '';

    installPhase = ''
      install -m 0755 -D -t $out/bin \
        zte-prometheus-exporter
    '';
  };
}
