final: prev: {
  libomxil-bellagio =
    if !final.stdenv.hostPlatform.isPower64 then prev.libomxil-bellagio
    else
      prev.libomxil-bellagio.overrideAttrs (o: {
        env.NIX_CFLAGS_COMPILE = (o.env.NIX_CFLAGS_COMPILE or "") + " -Wno-error=stringop-truncation";
      });
}
