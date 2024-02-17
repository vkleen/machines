{ ... }:
final: prev: {
  openexr_2 = prev.openexr_2.overrideAttrs (o: {
    doCheck = false;
  });
  openexr_3 = prev.openexr_3.overrideAttrs (o: {
    doCheck = false;
  });
}
