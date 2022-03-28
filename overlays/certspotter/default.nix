final: prev: {
  certspotter = final.buildGoPackage rec {
    pname = "certspotter";
    version = "0.11";

    src = (final.fetchFromGitHub {
      owner = "SSLMate";
      repo = "certspotter";
      rev = version;
      hash = "sha256-KTbEmaKaqEIqMaLFM28jb8ehjtlXqPGkNJ2sxHrVrI8=";
    });
    goPackagePath = "cmd/certspotter";
    goDeps = ./deps.nix;
  };
}
