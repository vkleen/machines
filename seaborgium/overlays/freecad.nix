self: super: {
  freecad = super.freecad.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ [ self.libspnav ];
  });
}
