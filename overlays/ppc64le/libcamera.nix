final: prev: {
  libcamera =
    if !final.stdenv.hostPlatform.isPower64 then prev.libcamera else
    prev.libcamera.overrideAttrs (o: {
      env.NIX_CFLAGS_COMPILE = "-mabi=ieeelongdouble";
    });
}
