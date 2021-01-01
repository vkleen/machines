self: super: {
  libsigrok = (super.libsigrok.override {
    version = "0.5.1";
    sha256 = "171b553dir5gn6w4f7n37waqk62nq2kf1jykx4ifjacdz5xdw3z4";
  }).overrideAttrs (o: rec {
    fx2-firmware = o.firmware;
    dslogic-firmware = ./dslogic-pro;

    postInstall = ''
      mkdir -p "$out/share/sigrok-firmware"
      tar --strip-components=1 -xvf "${fx2-firmware}" -C "$out/share/sigrok-firmware"
      cp "${dslogic-firmware}"/* $out/share/sigrok-firmware
    '';
  });
}
