attrs@{ lib, trilby, ... }:
final: prev: lib.optionalAttrs (trilby.hostSystem.cpu.name == "powerpc64le") (
  lib.composeManyExtensions
    (builtins.map (v: import v attrs) (lib.findModulesList ./.))
    final
    prev
)
