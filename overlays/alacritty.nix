final: prev: {
  alacritty = prev.alacritty.overrideAttrs (drv: rec {
    name = "alacritty-${version}";
    version = "master";

    src = final.alacritty-src;
    cargoDeps = drv.cargoDeps.overrideAttrs (_: {
      inherit src;
      patches = [];
      outputHash = "sha256-rwKxfUsUoNxHUhg4r0rfKQcK82QXpLOGt9uIb9FCLqQ=";
    });

    patches = [];

    doCheck = false;
  });
}
