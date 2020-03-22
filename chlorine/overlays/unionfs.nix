self: super: {
  unionfs-fuse = super.unionfs-fuse.overrideAttrs (o: {
    nativeBuildInputs = [ self.cmake ];
    buildInputs = [ self.fuse ];
  });
}
