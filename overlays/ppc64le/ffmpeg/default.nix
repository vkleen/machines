final: prev: {
  ffmpeg_4 =
    if !final.stdenv.hostPlatform.isPower64 then prev.ffmpeg_4 else
    (prev.ffmpeg_4.override {
      withMfx = false;
    }).overrideAttrs (o: {
      patches = (o.patches or [ ]) ++ [ ./powerpc-altivec.patch ];
      doCheck = false;
    });

  ffmpeg_5 =
    if !final.stdenv.hostPlatform.isPower64 then prev.ffmpeg_5 else
    (prev.ffmpeg_5.override {
      withMfx = false;
    }).overrideAttrs (o: {
      patches = (o.patches or [ ]) ++ [ ./powerpc-altivec.patch ];
      doCheck = false;
    });

  ffmpeg_6 =
    if !final.stdenv.hostPlatform.isPower64 then prev.ffmpeg_6 else
    (prev.ffmpeg_6.override {
      withMfx = false;
    }).overrideAttrs (o: {
      patches = (o.patches or [ ]) ++ [ ./powerpc-altivec.patch ];
      doCheck = false;
    });
}
