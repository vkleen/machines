{ stdenv, fetchurl, fetchFromGitHub, sconsPackages, libuv, libunwind, openfec, pulseaudio, libtool, libjson, libsndfile, alsaLib, sox, ragel, gengetopt, cpputest }:
assert (with stdenv.targetPlatform; isx86_64 && isLinux);
let
  libtool_src = fetchurl {
    url = "ftp://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz";
    hash = "sha256-471NXT0CWjbCHdavfqgYoq/NTfwepaF7OdeFS80MBuM=";
  };
  sndfile_src = fetchurl {
    url = "http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.20.tar.gz";
    hash = "sha256-dRfrlmV5+IFLXv4wfLkZxbTntcZykgm6HalfMeg2jcc=";
  };
  json_c_0_11 = fetchurl {
    url = "https://github.com/json-c/json-c/archive/json-c-0.11-20130402.tar.gz";
    hash = "sha256-mYgoNAjHGDjY1i5UGOWrtetTAL2Ew4X9yWFDtejxDtU=";
  };

in stdenv.mkDerivation {
  name = "roc-toolkit";
  version = "v0.1.5";
  src = fetchFromGitHub {
    owner = "roc-streaming";
    repo = "roc-toolkit";
    rev = "06c7730f6e6cc8d11b24d0c460297d3b2de17bfe";
    hash = "sha256-UwWclINqbdM7F634+kQZsMLugGiS02W3rd8P9RBB5gU=";
  };
  buildInputs = [
    sconsPackages.scons_3_1_2 libuv libunwind openfec
    libtool libjson libsndfile alsaLib
    sox ragel gengetopt cpputest
  ];
  preConfigure = ''
    mkdir -p 3rdparty/x86_64-pc-linux-gnu/gcc-${stdenv.cc.version}-release/build/ltdl-2.4.6/src \
             3rdparty/x86_64-pc-linux-gnu/gcc-${stdenv.cc.version}-release/build/json-0.11-20130402/src \
             3rdparty/x86_64-pc-linux-gnu/gcc-${stdenv.cc.version}-release/build/sndfile-1.0.20/src \
             3rdparty/x86_64-pc-linux-gnu/gcc-${stdenv.cc.version}-release/build/pulseaudio-${pulseaudio.version}/src
    cp ${libtool_src} 3rdparty/x86_64-pc-linux-gnu/gcc-${stdenv.cc.version}-release/build/ltdl-2.4.6/src/libtool-2.4.6.tar.gz
    cp ${json_c_0_11} 3rdparty/x86_64-pc-linux-gnu/gcc-${stdenv.cc.version}-release/build/json-0.11-20130402/src/json-0.11-20130402.tar.gz
    cp ${sndfile_src} 3rdparty/x86_64-pc-linux-gnu/gcc-${stdenv.cc.version}-release/build/sndfile-1.0.20/src/libsndfile-1.0.20.tar.gz

     xz -d < ${pulseaudio.src} | gzip > 3rdparty/x86_64-pc-linux-gnu/gcc-${stdenv.cc.version}-release/build/pulseaudio-${pulseaudio.version}/src/pulseaudio-${pulseaudio.version}.tar.gz
  '';
  sconsFlags = [
    "--enable-pulseaudio-modules"
    "--with-openfec-includes=${openfec}/include/openfec"
    "--build-3rdparty=pulseaudio:${pulseaudio.version}"
    "--prefix=${placeholder "out"}"
  ];
}
