final: prev: {
  radicale = final.radicale3;
  radicale3 = prev.radicale3.overrideAttrs (_: {
    src = final.radicale-src;
  });
}
