{ ... }:
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pfinal: pprev: {
      # selenium-manager depends on a pinned ring version which doesn't have the PPC64le patches, yet
      django = pprev.django.override { selenium = null; };
    })
  ];
}
