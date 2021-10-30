final: prev: {
  alacritty = prev.alacritty.overrideAttrs (drv: rec {
    version = "master";

    src = final.alacritty-src;
    cargoDeps = drv.cargoDeps.overrideAttrs (_: {
      inherit src;
      patches = [];
      outputHash = "sha256-X2s7takCCYoSfqh/tn7v2jWxFoYCeAppxz9oMSKoA5w=";
    });

    patches = [];

    doCheck = false;
  });
}
