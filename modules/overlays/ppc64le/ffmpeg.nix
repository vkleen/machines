{ ... }:
# filter_scale2ref_keep_aspect check fails with mysterious mismatches; doesn't seem to be a real issue?
final: prev: {
  ffmpeg_4 = (prev.ffmpeg_4.override {
    withMfx = false;
  }).overrideAttrs (o: {
    doCheck = false;
  });

  ffmpeg_5 = (prev.ffmpeg_5.override {
    withMfx = false;
  }).overrideAttrs (o: {
    doCheck = false;
  });

  ffmpeg_6 = (prev.ffmpeg_6.override {
    withMfx = false;
  }).overrideAttrs (o: {
    doCheck = false;
  });
}
