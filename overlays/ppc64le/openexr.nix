final: prev: {
  openexr_2 =
    if !final.stdenv.hostPlatform.isPower64
    then prev.openexr_2 else
      prev.openexr_2.overrideAttrs (o: {
        doCheck = false;
      });
  openexr_3 =
    if !final.stdenv.hostPlatform.isPower64
    then prev.openexr_3 else
      prev.openexr_3.overrideAttrs (o: {
        doCheck = false;
      });
}
