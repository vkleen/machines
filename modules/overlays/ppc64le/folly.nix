{ ... }:
final: prev: {
  folly = prev.folly.overrideAttrs (o: {
    meta = o.meta // {
      platforms = o.meta.platforms ++ [ "powerpc64le-linux" ];
    };
  });
}
