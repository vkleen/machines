final: prev: {
  libsigrok = prev.libsigrok.overrideAttrs (o: rec {
    dslogic-firmware = ./dslogic-pro;

    postInstall = o.postInstall + ''
      cp "${dslogic-firmware}"/* $out/share/sigrok-firmware
    '';
  });
}
