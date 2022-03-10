final: prev: {
  alacritty = prev.alacritty.overrideAttrs (drv: rec {
    name = "alacritty-${version}";
    version = "master";

    src = final.alacritty-src;
    cargoDeps = drv.cargoDeps.overrideAttrs (_: {
      inherit src;
      patches = [];
      outputHash = "sha256-0AbuJXZ1O8N6oNIh3ykGXACgL2nX4MyVBM0nTbD3sKY=";
    });
    passthru = drv.passthru // { inherit cargoDeps; };

    patches = [];

    doCheck = false;
  });
}
