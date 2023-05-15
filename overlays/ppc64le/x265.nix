final: prev: {
  x265 =
    if !final.stdenv.hostPlatform.isPower64
    then prev.x265 else
      prev.x265.override {
        numaSupport = true;
        unittestsSupport = false;
      };
}
