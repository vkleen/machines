{ ... }:
final: prev: {
  jrnl = prev.jrnl.overridePythonAttrs (o: {
    doCheck = false;
  });
}
