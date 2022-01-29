final: prev: {
  swaylock = prev.swaylock.overrideAttrs (o: {
    mesonFlags = [
      "-Dpam=enabled"
      "-Dgdk-pixbuf=enabled"
      "-Dman-pages=enabled"
    ];
  });
}
