{ buildGoModule, fetchFromGitHub, lib, bfd-src }:

buildGoModule rec {
  pname = "bfd";
  version = "flake";

  src = bfd-src;

  vendorSha256 =  "sha256-Ck18/W6WT137R0PmYtSLF/G9ezMud1iIZT02BLQKmas=";

  subPackages = [ "cmd/bfd" ];
}
