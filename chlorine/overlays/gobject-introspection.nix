self: super: {
  gobject-introspection = (super.gobject-introspection.override { x11Support = false; }).overrideAttrs (o: {
    nativeBuildInputs = o.nativeBuildInputs ++ [ self.python3 self.flex self.bison ];
  });
}
