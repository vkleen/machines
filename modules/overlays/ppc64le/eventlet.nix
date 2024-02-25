{ ... }:
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pfinal: pprev: {
      eventlet = pprev.eventlet.overridePythonAttrs (o: {
        disabledTestPaths = o.disabledTestPaths ++ [
          "tests/greendns_test.py"
          "tests/socket_test.py"
          "tests/greenio_test.py"
        ];
      });
    })
  ];
}
