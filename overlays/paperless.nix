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
      patches = [ ./paperless-lobotomize-classifier.patch ];
      installCheckPhase = ":";
    });
}
