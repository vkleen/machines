final: prev: {
  gettext =
    if !final.stdenv.hostPlatform.isPower64 then prev.gettext else
    prev.gettext.overrideAttrs (o: {
      patches = (o.patches or [ ]) ++ [ ./gettext-0.21-fix-powerpc-ftbfs.patch ];
    });
}
