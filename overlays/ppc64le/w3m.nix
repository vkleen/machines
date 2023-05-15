final: prev: {
  w3m = prev.w3m.override {
    mouseSupport = !final.stdenv.hostPlatform.isPower64;
  };
}
