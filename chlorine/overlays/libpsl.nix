self: super: {
  libpsl = super.libpsl.overrideAttrs (_: {
    doCheck = false;
  });
}
