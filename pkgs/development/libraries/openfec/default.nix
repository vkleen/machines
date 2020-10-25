{ stdenv, fetchFromGitHub, cmake }:
stdenv.mkDerivation {
  name = "openfec";
  version = "1.4.2";
  src = fetchFromGitHub {
    owner = "roc-streaming";
    repo = "openfec";
    rev = "b6d32edc75e66d5e036c9346fd0852be09863e8e";
    hash = "sha256-o8ar+hBB4Da4d4rziLnnDmZh0dQyiBxxz8lVj5dqQCo=";
  };
  buildInputs = [ cmake ];
  installPhase = ''
    mkdir -p $out/bin $out/lib $out/include
    cp -d ../bin/Release/eperftool \
          ../bin/Release/simple_client \
          ../bin/Release/simple_server \
          ../bin/Release/test_code_params \
          ../bin/Release/test_create_instance \
          ../bin/Release/test_encoder_instance \
          $out/bin
    cp -d ../bin/Release/libopenfec.so \
          ../bin/Release/libopenfec.so.1 \
          ../bin/Release/libopenfec.so.1.4.2 \
          $out/lib
    cp -R -d ../src $out/include/openfec
  '';
}
