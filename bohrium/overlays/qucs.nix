self: super: {
  qucs = super.qucs.overrideAttrs (o: {
    src = self.fetchFromGitHub {
      owner = "ra3xdh";
      repo = "qucs_s";
      rev = "6101bb703b2f2b5100f688123f1cc36d67752089";
      sha256 = "1zk5l115bdh3sdr42qpl07j9drw054aykhdsg3r5nylrk5m8hl9j";
    };
    patches = [];
    buildInputs = o.buildInputs ++ [ self.ngspice ];
  });
}
