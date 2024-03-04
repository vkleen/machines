{ inputs, lib, pkgs, ... }:
let
  pkgs' = pkgs;
in
let
  pkgs = pkgs'.extend inputs.rust-overlay.overlays.default;
  rust = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.complete);
  craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rust;

  src = lib.cleanSourceWith {
    src = lib.cleanSource (craneLib.path ./.);
    filter = craneLib.filterCargoSources;
  };

  commonArgs = {
    inherit src;
  };

  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
craneLib.buildPackage (commonArgs // {
  inherit cargoArtifacts;

  buildInputs = [ pkgs.udev ];

  nativeBuildInputs = [ pkgs.pkg-config ];

  passthru.shellInputs = [
    rust
  ];
})
