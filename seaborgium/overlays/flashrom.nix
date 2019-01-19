self: super: {
  flashrom = super.flashrom.overrideAttrs (o: {
    src = self.fetchgit {
      url = "https://review.coreboot.org/flashrom.git";
      rev = "v1.0";
      sha256 = "0hvfajhp9zls0fkkbcc950i1s3fh8gqqpq824ca3f99vgh9ysyn5";
      fetchSubmodules = false;
    };
    preConfigure = ''
      export PREFIX=$out
      export CONFIG_CH341A_SPI=n
    '';
  });
}
