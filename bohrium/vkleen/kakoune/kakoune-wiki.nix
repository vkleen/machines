{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "kakoune-wiki";
  version = "unstable";
  src = fetchFromGitHub {
    owner = "TeddyDD";
    repo = "kakoune-wiki";
    rev = "53e22550ad8a15d7868a4e79fb4c4e784cdee978";
    hash = "sha256:1299zg4w1rsn2knlbkzvp6z1jh0y7710wf3z3m2wxhy38kv91fyc";
  };
  installPhase = ''
    mkdir -p $out/share/kak/autoload
    cp rc/*.kak $out/share/kak/autoload
  '';
}
