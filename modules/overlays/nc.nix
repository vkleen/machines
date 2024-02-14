{ trilby, lib, ... }:
final: prev: lib.optionalAttrs (trilby.hostSystem.cpu.name == "powerpc64le") {
  libressl.nc = final.netcat-openbsd;
}
