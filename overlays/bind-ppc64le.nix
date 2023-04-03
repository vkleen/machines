final: prev: {
  bind = prev.bind.overrideAttrs (o: {
    doCheck = o.doCheck && !final.stdenv.hostPlatform.isPower64;
  });
}
