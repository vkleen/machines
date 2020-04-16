{ fetchgit, rustPlatform, stdenv, pam }:
with rustPlatform;
buildRustPackage rec {
  pname = "greetd";
  version = "git";

  src = fetchgit {
    url = "https://git.sr.ht/~kennylevinsen/greetd";
    rev = "f82ad56d9e08c56c84b72483cf4677a1a74f3";
    sha256 = "0hz0qbj554iqwbr0chijhd4zkqlcwny1cr1yxip6am8iiqdaxir7";
  };

  buildInputs = [ pam ];

  cargoSha256 = "13mq8mv0cziha3vqym51hmk37fff19r25pd1zf4qsqb3jgnjs5xr";
}
