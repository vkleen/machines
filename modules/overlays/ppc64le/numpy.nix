{ ... }:
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pfinal: pprev: {
      numpy = pprev.numpy.overridePythonAttrs (o: {
        disabledTests = o.disabledTests ++ [
          "test_ppc64_ibm_double_double128"
          "test_features"
        ];
      });
    })
  ];
}
