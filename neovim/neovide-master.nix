{ neovide-src, neovide-cargoHash }:
final: prev: {
  neovide = prev.neovide.overrideAttrs (o: rec {
    name = "neovide-master";
    src = neovide-src;
    cargoDeps = o.cargoDeps.overrideAttrs (final.lib.const {
      name = "${name}-vendor.tar.gz";
      inherit src;
      outputHash = neovide-cargoHash;
    });
    passthru = o.passthru // { inherit cargoDeps; };
  });
}
