final: prev: {
  kicad-master = prev.kicad-unstable.override {
    srcs = {
      kicadVersion = "2020-12-08";
      kicad = prev.fetchFromGitLab {
        group = "kicad";
        owner = "code";
        repo = "kicad";
        rev = "e38b34a4eb1a03e372b887dee0836b60b0442147";
        sha256 = "sha256-gEf6FeygJWw1EVeEccC2KnRoGtt2Rl+zcUpm4Ax91/U=";
      };
    };
  };
}
