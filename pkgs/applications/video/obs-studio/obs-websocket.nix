{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, cmake
, qtbase
, obs-studio
, websocketpp
, asio
}:

stdenv.mkDerivation rec {
  pname = "obs-websocket";
  version = "11326274e06d0b3c33d4c1f75115cf5a25cd9170";

  src = fetchFromGitHub {
    owner = "Palakis";
    repo = "obs-websocket";
    rev = version;
    hash = "sha256-fV5queIKyvqsgKhg3nx5RKN1SHj9ywG3lL9H7SoUctU=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ qtbase websocketpp asio obs-studio ];

  cmakeFlags = with lib; [
    "-DLIBOBS_INCLUDE_DIR=${obs-studio.src}/libobs"
  ];

  # obs-studio expects the shared object to be located in bin/32bit or bin/64bit
  # https://github.com/obsproject/obs-studio/blob/d60c736cb0ec0491013293c8a483d3a6573165cb/libobs/obs-nix.c#L48
  postInstall = let
    pluginPath = {
      i686-linux = "bin/32bit";
      x86_64-linux = "bin/64bit";
    }.${stdenv.targetPlatform.system} or (throw "Unsupported system: ${stdenv.targetPlatform.system}");
  in ''
    mkdir -p $out/share/obs/obs-plugins/obs-websocket/${pluginPath}
    ln -s $out/lib/obs-plugins/obs-websocket.so $out/share/obs/obs-plugins/obs-websocket/${pluginPath}
  '';
}
