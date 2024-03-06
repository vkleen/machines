{ ... }:
final: prev: {
  tzdata = prev.tzdata.overrideAttrs (o: {
    doCheck = false;
  });
}
