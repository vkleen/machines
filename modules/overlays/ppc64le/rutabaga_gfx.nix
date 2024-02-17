{ ... }:
final: prev: {
  rutabaga_gfx = prev.rutabaga_gfx.overrideAttrs (o: {
    meta = o.meta // {
      badPlatforms = o.badPlatforms or [ ] ++ [ "powerpc64le-linux" ];
    };
  });
}
