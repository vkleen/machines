final: prev: {
  kicad-master = (prev.kicad-unstable.override {
    srcs = {
      kicadVersion = "master";
      kicad = final.kicad-src;
    };
    stable = false;
    doCheck = false;
  });
}
