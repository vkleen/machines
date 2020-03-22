self: super: {
  autoconf = super.autoconf.overrideAttrs (o: {
    configureFlags = o.configureFlags or [] ++ [ "--build=powerpc64le-unknown-linux-gnu" ];
  });
}
