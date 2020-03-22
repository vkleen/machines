self: super: {
  udp2raw = self.pkgsMusl.stdenv.mkDerivation {
    name = "udp2raw";
    src = self.fetchFromGitHub {
      repo = "udp2raw-tunnel";
      owner = "wangyu-";
      rev = "5cc304a26181ee17bc583b79a2e80449ea63e1b7";
      sha256 = "0j6l33rnxk0zf3xmg1x0k8ffzp11y124k2m8nfj1568zjy3qcdif";
    };
    patches = [ ./udp2raw-makefile.patch ];
    configurePhase = "";
    buildPhase = ''
      make amd64
    '';
    installPhase = ''
      install -Dm755 udp2raw_amd64 $out/bin/udp2raw
    '';
  };
}
