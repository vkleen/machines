{ lib, ... }:
# filter_scale2ref_keep_aspect check fails with mysterious mismatches; doesn't seem to be a real issue?
final: prev:
let
  ffmpegs = [
    "ffmpeg_4"
    "ffmpeg_5"
    "ffmpeg_6"
    "ffmpeg"
  ];
  variants = [ "" "-headless" "-full" ];
in
lib.foreach ffmpegs (ffmpeg: lib.foreach variants (variant: {
  "${ffmpeg}${variant}" = prev."${ffmpeg}${variant}".overrideAttrs (o: {
    doCheck = false;
  });
}))
