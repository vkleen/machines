final: prev: {
  alacritty = prev.alacritty.overrideAttrs (drv: rec {
    name = "alacritty-${version}";
    version = "master";

    src = final.alacritty-src;
    cargoDeps = drv.cargoDeps.overrideAttrs (_: {
      inherit src;
      patches = [];
      outputHash = "sha256-ADAz/G46EEkzIYKJpsAzahtC8idiwSAiljFufBzMCic=";
    });
    passthru = drv.passthru // { inherit cargoDeps; };

    patches = [];

    doCheck = false;
  });
}
