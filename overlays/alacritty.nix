final: prev: {
  alacritty = prev.alacritty.overrideAttrs (drv: rec {
    name = "alacritty-${version}";
    version = "master";

    src = final.alacritty-src;
    cargoDeps = drv.cargoDeps.overrideAttrs (_: {
      inherit src;
      patches = [];
      outputHash = "sha256-SQNAl93ih/gTvBIY9bvP9aTXptuyRy91vK9AXZPJr70=";
    });

    patches = [];

    doCheck = false;
  });
}
