self: super: {
  boost171 = super.boost171.override {
    patches = [ ./boost.patch ];
  };
  nix = super.nixStable.override {
    boost = self.boost171;
  };
}
