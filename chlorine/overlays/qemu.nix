self: super: {
  qemu = super.qemu.override {
    sdlSupport = false;
    gtkSupport = false;
    vncSupport = false;
    numaSupport = true;
  };
  libjpeg = super.libjpeg.overrideAttrs (o: {
    doCheck = false;
  });
}
