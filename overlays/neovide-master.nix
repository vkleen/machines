final: prev: {
  neovide = prev.neovide.overrideAttrs (o: rec {
    name = "neovide-master";
    src = final.neovide-src;
    cargoDeps = o.cargoDeps.overrideAttrs (final.lib.const {
      name = "${name}-vendor.tar.gz";
      inherit src;
      outputHash = "sha256-NVOVgyd0273uECJ3SANhhX5wB0nYkCcvzJf6pWNHLd4=";
    });
  });
}
