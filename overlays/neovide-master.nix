final: prev: {
  neovide = prev.neovide.overrideAttrs (o: rec {
    name = "neovide-master";
    src = final.neovide-src;
    cargoDeps = o.cargoDeps.overrideAttrs (final.lib.const {
      name = "${name}-vendor.tar.gz";
      inherit src;
      outputHash = "sha256-TQEhz9FtvIb/6Qtyz018dPle0+nub1oMZMFtKAqYcoI=";
    });
  });
}
