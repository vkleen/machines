self: super: {
  autoconf = super.autoconf.overrideAttrs (o: {
    configureFlags = o.configureFlags or [] ++ [ "--build=powerpc64le-unknown-linux-gnu" ];
  });
  cdparanoia = super.cdparanoia.overrideAttrs (o: {
    configureFlags = o.configureFlags or [] ++ [ "--build=powerpc64le-unknown-linux-gnu" ];
  });
  gnome2 = super.gnome2 // {
    gnome-mime-data = super.gnome2.gnome-mime-data.overrideAttrs (o: {
      configureFlags = o.configureFlags or [] ++ [ "--build=powerpc64le-unknown-linux-gnu" ];
    });
  };
}
