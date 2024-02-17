{ ... }:
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pfinal: pprev: {
      afdko = pprev.afdko.overridePythonAttrs (o: {
        disabledTests = o.disabledTests ++ [ "tests/makeotfexe_test.py" ];
      });
    })
  ];
}
