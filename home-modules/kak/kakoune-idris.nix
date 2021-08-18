{ stdenv, nodejs, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "kakoune-idris";
  version = "unstable";
  src = fetchFromGitHub {
    owner = "vkleen";
    repo = "kakoune-idris";
    rev = "1acdfb5d89e3951ae4bdf4a5fa2377b36448083d";
    hash = "sha256-OUmzP9B98VUHIlFrROWs0LDdw+HeXaDlPi1JkA7yFhs=";
  };
  installPhase = ''
    mkdir -p $out/share/kak/autoload
    substitute idris.kak $out/share/kak/autoload/idris.kak \
      --replace node "${nodejs}/bin/node" \
      --replace '%sh{dirname "$kak_source"}' "\"$src\""
  '';
}
