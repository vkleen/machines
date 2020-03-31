{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "kakoune-change-directory";
  version = "unstable";
  src = fetchFromGitHub {
    owner = "alexherbo2";
    repo = "change-directory.kak";
    rev = "3ae31a18a2ecd5461f526f9ca66e98470fb28ef2";
    sha256 = "0fb8ki3ym5w7d9qfr7vilwjb3n2lazx9y3pal8ddp00k0lwjya08";
  };
  installPhase = ''
    mkdir -p $out/share/kak/autoload
    cp rc/* $out/share/kak/autoload
  '';
}
