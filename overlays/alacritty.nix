final: prev: {
  alacritty = prev.alacritty.overrideAttrs (drv: rec {
    name = "alacritty-${version}";
    version = "master";

    src = final.alacritty-src;
    cargoDeps = drv.cargoDeps.overrideAttrs (_: {
      inherit src;
      patches = [];
      outputHash = "sha256-U/Gkapdw/8pzHj/lzu2L72mrVSnyvpioEEpjwjG0E3Y=";
    });

    patches = [];

    doCheck = false;
  });
}
