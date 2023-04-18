final: prev: {
  seatd = prev.seatd.overrideAttrs (o: {
    postPatch = o.postPatch or "" + ''
      substituteInPlace seatd-launch/seatd-launch.c --replace 'SEATD_INSTALLPATH' "\"$bin/bin/seatd\""
    '';
  });
}
