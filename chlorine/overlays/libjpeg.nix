self: super: {
  libjpeg_turbo = super.libjpeg_turbo.overrideAttrs (o: {
    doInstallCheck = false;
  });
}
