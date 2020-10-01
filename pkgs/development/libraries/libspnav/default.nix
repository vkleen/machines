{lib, stdenv, xorg, fetchFromGitHub}:

stdenv.mkDerivation rec {
  name = "libspnav";
  version = "20200225";
  src =  fetchFromGitHub {
    repo = "libspnav";
    owner = "vkleen";
    rev = "0104dcaae7f513f9f0b5b83c72c6b8f27bdaaf4d";
    hash = "sha256-OuoipqYL1Ro14+QwFIguUrxPwyj34cSvEBGITFqvT3Q=";
  };
  buildInputs = [ xorg.libX11 ];
}
