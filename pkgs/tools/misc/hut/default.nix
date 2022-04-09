{ lib, buildGoModule, hut-src }:
let
  src = hut-src;
in buildGoModule {
  name = "hut";
  version = "flake";
  inherit src;
  vendorSha256 = "sha256-EmokL3JlyM6C5/NOarCAJuqNsDO2tgHwqQdv0rAk+Xk=";
}
