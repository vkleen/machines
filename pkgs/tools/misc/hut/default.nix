{ lib, buildGoModule, hut-src }:
let
  src = hut-src;
in buildGoModule {
  name = "hut";
  version = "flake";
  inherit src;
  vendorSha256 = "sha256-auAdHjOUsWZ/BWJpxoXrrCA7NPs63pB8eaRgvggOQwI=";
}
