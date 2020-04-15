{stdenv, xorg, fetchurl}:

stdenv.mkDerivation rec {
  name = "spacenavd";
  version = "0.6";
  src = fetchurl {
    url = "http://download.sourceforge.net/spacenav/${name}-${version}.tar.gz";
    sha256 = "1ayhi06pv5lx36m5abwbib1wbs75svjkz92605cmkaf5jszh7ln2";
  };
  buildInputs = [ xorg.libX11 ];
  patches = [ ./no-hardcoded-paths.patch ];
}
