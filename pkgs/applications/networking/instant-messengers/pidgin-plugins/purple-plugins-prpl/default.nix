{ stdenv, pidgin, pkg-config, glib, fetchFromGitHub }:
stdenv.mkDerivation {
  pname = "purple-plugins-prpl";
  version = "2019-05-07";
  src = fetchFromGitHub {
    owner = "EionRobb";
    repo = "purple-plugins-prpl";
    rev = "c74912493ef596cc8a41ba60554858612d99b104";
    hash = "sha256:1acx1ha0iyx6im79h1ayg79hn863b76kbln1kl7q42ljabbilw5v";
  };
  buildInputs = [ pidgin pkg-config glib ];
  installPhase = ''
    install -Dm755 -t $out/lib/purple-2 libprpl.so
  '';
}
