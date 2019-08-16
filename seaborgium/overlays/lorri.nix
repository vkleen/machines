self: super: {
  lorri = self.rustPlatform.buildRustPackage rec {
    name = "lorri";

    src = self.fetchFromGitHub {
      owner = "target";
      repo = "lorri";
      rev = "9545a5c7ddf6a5e784fe500219397befc55890f6";
      sha256 = "1ar7clza117qdzldld9qzg4q0wr3g20zxrnd1s51cg6gxwlpg7fa";
    };

    BUILD_REV_COUNT = src.revCount or 1;
 
    cargoSha256 = "04v9k81rvnv3n3n5s1jwqxgq1sw83iim322ki28q1qp5m5z7canv";

    NIX_PATH = "nixpkgs=${src}/nix/bogus-nixpkgs";

    nativeBuildInputs = [ ];
    buildInputs = [ self.nix ];

    preCheck = ''
      . ${src}/nix/pre-check.sh
    '';

    doCheck = true;
  };
}
