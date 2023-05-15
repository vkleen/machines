final: prev: {
  assimp = prev.assimp.overrideAttrs (o: {
    env.NIX_CFLAGS_COMPILE = toString [
      (o.env.NIX_CFLAGS_COMPILE or "")
      "-Wno-error=free-nonheap-object"
    ];
  });
}
