{ trilby, lib, ... }:
final: prev: lib.optionalAttrs (trilby.hostSystem.cpu.name == "powerpc64le") {
  crun = (prev.crun.override { criu = null; }).overrideAttrs (o: {
    NIX_LDFLAGS = "";
  });
}
