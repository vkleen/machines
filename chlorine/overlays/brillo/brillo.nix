{ stdenv, go-md2man, coreutils, fetchFromGitLab }:
stdenv.mkDerivation rec {
  pname = "brillo";
  version = "v1.4.3";
  src = fetchFromGitLab {
    owner = "cameronnemo";
    repo = pname;
    rev = version;
    sha256 = "1syv3iav7bwr84x9frz1qd6qmgp8ldbjs4gl3r94nhllkai9spaq";
  };
  buildInputs = [ go-md2man ];
  makeFlags = [ "PREFIX=/" "DESTDIR=${placeholder "out"}" "GOMD2MAN=${go-md2man}/bin/go-md2man" "install-dist" ];
  postPatch = ''
    substituteInPlace contrib/90-brillo.rules --replace /bin/ ${coreutils}/bin/
  '';
}
