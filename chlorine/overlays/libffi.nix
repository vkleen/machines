self: super: {
  libffi = super.libffi.overrideAttrs (_: {
    configureFlags = if ! self.stdenv.targetPlatform.isPower then null else [
      "--with-gcc-arch=power9"
      "--enable-pax_emutramp"
    ];
    NIX_CFLAGS_COMPILE = if ! self.stdenv.targetPlatform.isPower then null else
      "-mfloat128";
  });
}
