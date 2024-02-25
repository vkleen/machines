{ ... }:
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pfinal: pprev: {
      scikit-learn = pprev.scikit-learn.overrideAttrs (o: {
        doInstallCheck = false;
      });
    })
  ];
}
