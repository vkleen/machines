{ ... }:
final: prev: {
  firefox-unwrapped = (prev.firefox-unwrapped.override {
    crashreporterSupport = false;
  }).overrideAttrs (o: {
    buildInputs = o.buildInputs or [ ] ++ [ final.binutils ];
  });
}
