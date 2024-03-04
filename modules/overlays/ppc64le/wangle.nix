{ ... }:
final: prev: {
  wangle = prev.wangle.overrideAttrs (o: {
    doCheck = false;
  });
}
