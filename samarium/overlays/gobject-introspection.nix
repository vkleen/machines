self: super: {
  gobject-introspection = super.gobject-introspection.override { x11Support = false; };
}
