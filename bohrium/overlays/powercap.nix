self: super: {
  powercap = self.stdenv.mkDerivation rec {
    name = "powercap-${version}";
    version = "0.1.1";
    src = self.fetchurl {
      url = "https://github.com/powercap/powercap/archive/v${version}.tar.gz";
      sha256 = "0i21mrn1ajqwwmkqcxr2myl3lgnyw45wrvx50i7i7hhj8ijbw0dy";
    };
    buildInputs = [ self.cmake ];
  };
}
