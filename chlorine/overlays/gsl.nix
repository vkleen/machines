self: super: {
  gsl = super.gsl.overrideAttrs (_: {
    doCheck = false;
  });
}
