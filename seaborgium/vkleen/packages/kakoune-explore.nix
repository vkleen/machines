{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "kakoune-explore";
  version = "unstable";
  src = fetchFromGitHub {
    owner = "alexherbo2";
    repo = "explore.kak";
    rev = "86fb1412521598d018e657fcfe8d1a026cfe8725";
    sha256 = "0dhf8mmz5nick3nd5dm4n788476clcq0r582zy63dk5vz0ypk9y8";
  };
  installPhase = ''
    mkdir -p $out/share/kak/autoload
    cp rc/explore/* $out/share/kak/autoload
  '';
}
