# This file was generated by https://github.com/kamilchm/go2nix v1.3.0
{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "fast-p-unstable-${version}";
  version = "2019-07-09";
  rev = "fe2c98d82af50cb8721def79411860b4424ed328";

  goPackagePath = "github.com/bellecp/fast-p";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/bellecp/fast-p";
    sha256 = "0508d07z9xirj08g51xmmrj5lm8ir3hgx0vld10kzjkbr7l8wxdb";
  };

  goDeps = ./deps.nix;

  # TODO: add metadata https://nixos.org/nixpkgs/manual/#sec-standard-meta-attributes
  meta = {
  };
}
