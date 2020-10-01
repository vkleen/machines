{lib, stdenv, xorg, fetchFromGitHub}:

stdenv.mkDerivation rec {
  name = "spacenavd";
  version = "";
  src = fetchFromGitHub {
    repo = "spacenavd";
    owner = "vkleen";
    rev = "00205d31a73eded1971955762c905b9b87a082ef";
    hash = "sha256-dL+HNCWAvQfK+y8SEbgPwPTDdDNWRZL8/xfSVVVCMrU=";
  };
  buildInputs = [ xorg.libX11 ];
}
