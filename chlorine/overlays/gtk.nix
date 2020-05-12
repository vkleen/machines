self: super: {
  gtk3 = super.gtk3.overrideAttrs (o: {
    postPatch = o.postPatch + ''
      sed -i 's/3.24.17/3.24.18/' meson.build
    '';
  });
}
