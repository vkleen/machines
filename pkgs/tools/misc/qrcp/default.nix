{ stdenv, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "qrcp";
  version = "master";
  src = fetchFromGitHub {
    owner = "claudiodangelis";
    repo = "qrcp";
    rev = "218dd17eb8e28cc46c140184b2e166c2e1fe034b";
    sha256 = "sha256-JTpjwXUvOf2sMcILDsaaD7S0JzmvApybloUT/y9jM5M=";
  };
  vendorSha256 = "sha256-Ck+mMwnVsNL2whHtbwUINZ6LdjgqJdozVEza0QfxzkU=";
  subPackages = [ "." ];
}
