{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "emoji-fzf";
  version = "master";

  src = fetchFromGitHub {
    owner = "mvertescher";
    repo = "emoji-fzf";
    rev = "ae66caa0032b884380dd4ff6ac311fd080a2db49";
    hash = "sha256-BWsmFPxoQiRM4JQ88GiQsE+FejQhqULBXYZ/z0Xt3xo=";
  };

  cargoHash = "sha256-iVH1oid4GiUUvX32k5YBfdaueRFwlytB/Cg7SUzwqco=";
  cargoPatches = [ ./add-cargo-lock.patch ];
}
