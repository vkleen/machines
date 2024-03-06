{ ... }:
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pfinal: pprev: {
      eventlet = pprev.eventlet.overridePythonAttrs (o: {
        disabledTests = o.disabledTests or [ ] ++ [
          "test_clear"
          "test_noraise_dns_tcp"
          "test_raise_dns_tcp"
          "test_dns_methods_are_green"
        ];
      });
    })
  ];
}
