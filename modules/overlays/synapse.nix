{ ... }:
final: prev: {
  python312 = prev.python312.override {
    packageOverrides = pfinal: pprev: {
      pysaml2 = pfinal.toPythonModule final.emptyDirectory;
    };
  };
  matrix-synapse-unwrapped = prev.matrix-synapse-unwrapped.overridePythonAttrs {
    doCheck = false;
  };
}
