self: super: {
  qemu = super.qemu.overrideAttrs (o: {
    configureFlags = (self.lib.remove "--enable-docs" o.configureFlags) ++ [ "--disable-docs" ];
  });
}
