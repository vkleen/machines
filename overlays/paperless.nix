final: prev: {
  paperless-ngx =
    let
      inherit (prev.paperless-ngx) python;
      django-celery-results = python.pkgs.pythonPackages.buildPythonPackage rec {
        pname = "django-celery-results";
        version = "2.4.0";

        src = final.fetchFromGitHub {
          owner = "celery";
          repo = pname;
          rev = "v${version}";
          sha256 = "sha256-1kNmrbQEG0Ye6l5gYVmMygRfEBLO4jZ/i5MlBPEpG1E=";
        };

        propagatedBuildInputs = with python.pkgs.pythonPackages; [
          django
          celery
        ];

        doCheck = false;
      };
    in
    prev.paperless-ngx.overrideAttrs (o: rec {
      # inherit (o) pname;
      # version = "1.10.2";
      # src = final.fetchurl {
      #   url = "https://github.com/paperless-ngx/paperless-ngx/releases/download/v${version}/${pname}-v${version}.tar.xz";
      #   hash = "sha256-uOrRHHNqIYsDbzKcA7EsYZjadpLyAB4Ks+PU+BNsTWE=";
      # };

      patches = [ ./paperless-lobotomize-classifier.patch ];

      # propagatedBuildInputs = o.propagatedBuildInputs ++ (with python.pkgs.pythonPackages; [
      #   celery
      #   django-celery-results
      #   rapidfuzz
      # ]);
      #
      # nativeBuildInputs = (o.nativeBuildInputs or [ ]) ++ [ final.gettext ];

      installCheckPhase = ":";
    });
}
