{ inputs, ... }:
final: prev: {
  lib = import "${inputs.trilby}/lib" {
    inherit (inputs.trilby) inputs;
    inherit (prev) lib;
  };
}
