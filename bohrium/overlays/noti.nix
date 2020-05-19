self: super: {
  noti = self.buildGoModule rec {
    name = "noti-${version}";
    version = "3.3.0";
    src = self.fetchFromGitHub {
      owner = "variadico";
      repo = "noti";
      rev = "4dab6def9a400e08bb1890b652bfafe2037597db";
      sha256 = "1644bivjcky07n3rrm83vsms7hw47p4hnp2536q0z3qca5jyri2f";
    };
    vendorSha256 = self.lib.fakeSha256;
    configurePhase = ''
      runHook preConfigure

      export GOCACHE=$TMPDIR/go-cache
      export GOPATH="$TMPDIR/go"

      runHook postConfigure
    '';
    preBuild = ''
      buildFlagsArray+=("-mod=vendor")
    '';
    subPackages = [ "cmd/noti" ];
  };
}
