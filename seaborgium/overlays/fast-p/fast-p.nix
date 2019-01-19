self: super: self.buildGoPackage rec {
  name = "fast-p-${version}";
  version = "0.2.4";

  goPackagePath = "github.com/bellecp/fast-p";
  src = self.fetchFromGitHub {
    owner = "bellecp";
    repo = "fast-p";
    rev = "v${version}";
    sha256 = "0idhknp30b3w5zp4h7md26qbzb63k4mwzgf0f31xjl3xspppsy5z";
  };

  goDeps = ./deps.nix;
}
