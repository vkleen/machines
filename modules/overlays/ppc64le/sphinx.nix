{ ... }:
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pfinal: pprev: {
      sphinx = pprev.sphinx.overrideAttrs (o: {
        doInstallCheck = false;
      });
    })
  ];
}
