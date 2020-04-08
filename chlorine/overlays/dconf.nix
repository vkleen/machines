self: super: {
  dconf = super.dconf.overrideAttrs (o: {
    doCheck = false;
  });
}
