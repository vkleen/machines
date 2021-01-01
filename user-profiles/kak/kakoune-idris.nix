{ stdenv, nodejs, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "kakoune-idris";
  version = "unstable";
  src = fetchFromGitHub {
    owner = "vkleen";
    repo = "kakoune-idris";
    rev = "a78832768a495919221f17e78d529e84c7c830c1";
    hash = "sha256:0mhc0vhivk6rmad3nah38ljijfg565s77qahxviscz13x0wj6bdv";
  };
  installPhase = ''
    mkdir -p $out/share/kak/autoload
    substitute idris.kak $out/share/kak/autoload/idris.kak \
      --replace node "${nodejs}/bin/node" \
      --replace '%sh{dirname "$kak_source"}' "\"$src\""
  '';
}
