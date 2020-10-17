final: prev: {
  freecad-realthunder = prev.freecad.overrideAttrs (o: {
    version = "realthunder";
    src = final.freecad-src;
    buildInputs = o.buildInputs ++ [ final.libspnav ];
  });
}
