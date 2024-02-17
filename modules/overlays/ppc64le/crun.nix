{ ... }:
final: prev: {
  crun = (prev.crun.override { criu = null; }).overrideAttrs (o: {
    NIX_LDFLAGS = "";
  });
}
