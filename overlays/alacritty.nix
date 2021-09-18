final: prev: {
  alacritty = prev.alacritty.overrideAttrs (drv: rec {
    version = "master";

    src = final.alacritty-src;
    cargoDeps = drv.cargoDeps.overrideAttrs (_: {
      inherit src;
      outputHash = "sha256-LtPn99KJ45sTsGBcTKCOsyAfEdwrtmWUAi9eP+jQgCs=";
    });

    doCheck = false;
  });
}
