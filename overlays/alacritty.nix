final: prev: {
  alacritty = prev.alacritty.overrideAttrs (drv: rec {
    name = "alacritty-${version}";
    version = "master";

    src = final.alacritty-src;
    cargoDeps = drv.cargoDeps.overrideAttrs (_: {
      inherit src;
      patches = [];
      outputHash = "sha256-BcbzRnXViK3EWoxd+74Z/nQ2/MQWJvQzZY6QvItw1EQ=";
    });
    passthru = drv.passthru // { inherit cargoDeps; };

    patches = [];

    doCheck = false;
  });
}
