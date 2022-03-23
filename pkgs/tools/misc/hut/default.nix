{ lib, buildGoModule, hut-src }:
let
  src = hut-src;
in buildGoModule {
  name = "hut";
  version = "flake";
  inherit src;
  vendorSha256 = "sha256-zdQvk0M1a+Y90pnhqIpKxLJnlVJqMoSycewTep2Oux4=";
}
