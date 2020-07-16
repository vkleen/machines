self: super: {
  chrony = super.chrony.overrideAttrs (o: {
    buildInputs = self.lib.remove super.texinfo o.buildInputs;
  });
}
