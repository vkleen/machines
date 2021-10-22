{ symlinkJoin, makeWrapper, python3Packages,
  ghostscript, poppler_utils, pdftk, qpdf, rmapi
}:
symlinkJoin {
  name = "rmapi-wrapped";
  paths = with python3Packages; [ (toPythonApplication paper2remarkable) ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/p2r \
      --add-flags --gs --add-flags ${ghostscript}/bin/gs \
      --add-flags --pdftoppm --add-flags ${poppler_utils}/bin/pdftoppm \
      --add-flags --pdftk --add-flags ${pdftk}/bin/pdftk \
      --add-flags --qpdf --add-flags ${qpdf}/bin/qpdf \
      --add-flags --rmapi --add-flags ${rmapi}/bin/rmapi
  '';
}
