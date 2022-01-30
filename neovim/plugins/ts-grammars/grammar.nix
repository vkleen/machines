# Build a parser grammar and put the resulting shared object in `$out/parser`

{
# language name
  language
# version of tree-sitter
, version
# source for the language grammar
, source
, location ? null
, lib, stdenv, libcxx, tree-sitter, nodejs
, abiVersion
, generateFromGrammar ? false
}:

stdenv.mkDerivation {
  pname = "${language}-grammar";
  inherit version;

  src = source;

  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";
  buildInputs = lib.optional generateFromGrammar [ tree-sitter nodejs ] ;

  configurePhase = ":";
  buildPhase = ''
    ${lib.optionalString (location != null) ''
      cd "${location}"
    ''}
    runHook preBuild
    scanner_cc="src/scanner.cc"
    if [ ! -f "$scanner_cc" ]; then
      scanner_cc=""
    fi
    scanner_c="src/scanner.c"
    if [ ! -f "$scanner_c" ]; then
      scanner_c=""
    fi
    ${lib.optionalString generateFromGrammar ''
      tree-sitter generate --abi ${abiVersion}
    ''}
    $CC -o parser.so -Isrc src/parser.c $scanner_cc $scanner_c -shared -Os -lstdc++ -fPIC
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir $out
    mv parser.so $out/parser
    runHook postInstall
  '';
}
