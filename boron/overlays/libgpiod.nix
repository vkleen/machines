self: super: {
  libgpiod = super.libgpiod.overrideAttrs (o: {
    configureFlags = o.configureFlags ++ [
      "ac_cv_func_malloc_0_nonnull=yes"
    ];
  });
}
