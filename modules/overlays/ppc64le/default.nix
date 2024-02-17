attrs@{ lib, trilby, ... }:
final: prev: lib.optionalAttrs (trilby.hostSystem.cpu.name == "powerpc64le") (
  lib.composeManyExtensions
    (lib.flip lib.mapAttrsToList (lib.findModules ./.) (
      _: v: import v attrs
    ))
    final
    prev
)
