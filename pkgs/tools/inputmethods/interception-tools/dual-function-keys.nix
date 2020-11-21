{ stdenv, fetchFromGitLab, libevdev, libyamlcpp }:

stdenv.mkDerivation rec {
  pname = "dual-function-keys";
  version = "master";
  rev = "9576119a561544c95b6c17fe602558dc955f4370";

  src = fetchFromGitLab {
    owner = "interception/linux/plugins";
    repo = pname;
    inherit rev;
    hash = "sha256-PEH615ui0ExJSYXoo4RCONh7lhMwHv1RsBIzGnaA8/g=";
  };

  configurePhase = ''
    sed -i -e 's,^PREFIX =.*$,PREFIX = '"$out"',' \
           -e 's,^INCS =.*$,INCS = -I${libevdev}/include/libevdev-1.0 -I${libyamlcpp}/include,' \
           -e 's,^LDFLAGS =,LDFLAGS = -L${libevdev}/lib -L${libyamlcpp}/lib,' \
           config.mk
  '';

  buildInputs = [ libevdev libyamlcpp ];
}
