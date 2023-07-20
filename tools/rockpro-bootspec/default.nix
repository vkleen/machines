{ inputs, lib, pkgs, system, ... }:
let
  rust = inputs.fenix.packages.${system}.latest;
  craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rust.toolchain;

  src = lib.cleanSourceWith {
    src = lib.cleanSource (craneLib.path ./.);
    filter = craneLib.filterCargoSources;
  };

  commonArgs = {
    inherit src;
  };

  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
  rockpro-bootspec = craneLib.buildPackage (commonArgs // {
    inherit cargoArtifacts;
  });
in
rec {
  package = rockpro-bootspec;
  devShell = pkgs.mkShell {
    inputsFrom = [ package ];
    nativeBuildInputs = [
      rust.rust-analyzer
      rust.rustfmt
    ];
  };
}
