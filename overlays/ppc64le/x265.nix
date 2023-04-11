final: prev: {
  x265 = prev.x265.override {
    numaSupport = true;
    unittestsSupport = false;
  };
}
