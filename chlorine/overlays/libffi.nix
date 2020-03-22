self: super: {
  libffi = super.libffi.overrideAttrs (_: {
    configureFlags = [
      "--with-gcc-arch=power9"
      "--enable-pax_emutramp"
    ];
    NIX_CFLAGS_COMPILE="-mfloat128";
  });
}
