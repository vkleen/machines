final: prev: {
  kicad-master = prev.kicad-unstable.override {
    srcs = {
      kicadVersion = "2020-12-09";
      kicad = prev.fetchFromGitLab {
        group = "kicad";
        owner = "code";
        repo = "kicad";
        rev = "eb2472650c01f4b086453ba5c75dde8a60232fc9";
        sha256 = "sha256-MTBX0WbdcN+0WIcJX0FBB5i3/v027Yo6EgRSCjxnqF0=";
      };
    };
  };
}
