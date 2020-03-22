self: super: {
  guile_2_0 = null;
  autogen = (super.autogen.override { guile = self.guile_2_2; }).overrideAttrs (o: {
    patches = [ ./allow-guile-2.2.diff ];
  });
}
