final: prev: {
  nushell = (prev.nushell.override { withStableFeatures = true; }).overrideAttrs (o: {
    # buildInputs = o.buildInputs ++ [ final.xorg.libX11 final.xorg.libxcb final.python3 ];
    cargoBuildFlags = "--features extra";
  });
}
