{ ... }:
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pfinal: pprev: {
      afdko = pprev.afdko.overridePythonAttrs (o: {
        disabledTestPaths = o.disabledTestPaths or [ ] ++ [ "tests/makeotfexe_test.py" ];
      });
    })
  ];
}
