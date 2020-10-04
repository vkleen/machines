{lib, stdenv, xorg, fetchFromGitHub}:

stdenv.mkDerivation rec {
  name = "spacenavd";
  version = "";
  src = fetchFromGitHub {
    repo = "spacenavd";
    owner = "vkleen";
    rev = "99aa1dbf8d73680e04cfd7f6af7b4ad57ae44b8f";
    hash = "sha256-oDbNGUx9bPjlX09rQAu0KX//9N1u2xslPgrpqAheufs=";
  };
  buildInputs = [ xorg.libX11 ];
}
