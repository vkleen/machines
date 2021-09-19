{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "emoji-fzf";
  version = "master";

  src = fetchFromGitHub {
    owner = "vkleen";
    repo = "emoji-fzf";
    rev = "bf023463f8b185309fe28b9b73f81dd6f75a4304";
    hash = "sha256-BWsmFPxoQiRM4JQ88GiQsE+FejQhqULBXYZ/z1Xt3xo=";
  };

  cargoHash = "sha256-iVH1oid4GiUUvX32k5YBfdaueRFwlytB/Cg8SUzwqco=";
}
