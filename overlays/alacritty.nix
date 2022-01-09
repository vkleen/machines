final: prev: {
  alacritty = prev.alacritty.overrideAttrs (drv: rec {
    name = "alacritty-${version}";
    version = "master";

    src = final.alacritty-src;
    cargoDeps = drv.cargoDeps.overrideAttrs (_: {
      inherit src;
      patches = [];
      outputHash = "sha256-u0qx3DC+48xFs1YVmHuAAC7tDxYsyB4OneZk/ujB2D0=";
    });
    passthru = drv.passthru // { inherit cargoDeps; };

    patches = [];

    doCheck = false;
  });
}
