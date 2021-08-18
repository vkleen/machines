{ mkDerivation, fetchFromGitHub, lib, qtbase, qtxmlpatterns, poppler, qmake, makeWrapper }:
mkDerivation {
  pname = "seamly2d";
  version = "develop";

  src = fetchFromGitHub {
    owner = "FashionFreedom";
    repo = "Seamly2D";
    rev = "6ac55e4220adb10cbe197fe90fe85216b95912d8";
    hash = "sha256-NWwn168g9FfuQw89ShvZSZ2/H4JYvKpRtrgSkoHoogo=";
  };

  patches = [ ./0001-Remove-hardcoded-cases-of-usr.patch ];

  buildInputs = [ qtbase qtxmlpatterns poppler qmake makeWrapper ];

  preConfigure = ''
    mkdir build-linux
    cd build-linux
  '';
  qmakeFlags = [
    "../Seamly2D.pro"
    "-spec"
    "linux-g++"
    "CONFIG+=release"
    "CONFIG+=no_ccache"
  ];

  postInstall = ''
    wrapProgram $out/bin/seamly2d --set QT_QPA_PLATFORM xcb
    wrapProgram $out/bin/seamlyme --set QT_QPA_PLATFORM xcb
  '';
}
