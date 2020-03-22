self: super: {
  qemu = (super.qemu.override {
    pulseSupport = false;
    sdlSupport = false;
    gtkSupport = false;
    vncSupport = false;
    spiceSupport = false;
    smartcardSupport = false;
    numaSupport = true;
    hostCpuTargets = [ "arm-softmmu" "aarch64-softmmu" "ppc64-softmmu" "mips-softmmu" "x86_64-softmmu" "i386-softmmu" "mips64el-softmmu" "arm-linux-user" "armeb-linux-user" "ppc64-linux-user" "ppc64abi32-linux-user" "mipsel-linux-user" "aarch64-linux-user" "x86_64-linux-user" "i386-linux-user" "mips64el-linux-user" ];
  }).overrideAttrs (o: {
    nativeBuildInputs = with self; [ python3 pkgconfig flex bison ];
    configureFlags = self.lib.remove "--enable-docs" o.configureFlags;
  });
  libjpeg = super.libjpeg.overrideAttrs (o: {
    doCheck = false;
  });
}
