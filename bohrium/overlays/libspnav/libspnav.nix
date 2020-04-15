{stdenv, xorg, fetchurl}:

stdenv.mkDerivation rec {
  name = "libspnav";
  version = "0.2.3";
  src = fetchurl {
    url = "http://download.sourceforge.net/spacenav/${name}-${version}.tar.gz";
    sha256 = "7ae4d7bb7f6a5dda28b487891e01accc856311440f582299760dace6ee5f1f93";
  };
  buildInputs = [ xorg.libX11 ];
  patches = [ ./no-hardcoded-paths.patch ];
}
