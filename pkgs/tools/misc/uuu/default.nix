{ stdenv, cmake, bzip2, libzip, libusb1, pkg-config, fetchgit }:
let rev = "5e5fee80e1902415ca5e3545df271b94b02c05e9";
    version = "1.2.91";
in stdenv.mkDerivation {
  name = "uuu";
  inherit version;

  src = fetchgit {
    url = "https://source.puri.sm/Librem5/mfgtools";
    inherit rev;
    sha256 = "12zc88lbwpcpa06c6cv5g9z4dv0xydq5nbm4q9zzh3kw1brwx2kz";
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ bzip2 libzip libusb1 ];

  postConfigure = ''
    mkdir -p libuuu/gen
    echo "#define GIT_VERSION \"${version}\"" > libuuu/gen/gitversion.h
  '';
}
