self: super: {
  libreoffice = super.libreoffice.override {
    libreoffice = super.libreoffice.libreoffice.overrideAttrs (_: {
      doCheck = false;
    });
  };
}
