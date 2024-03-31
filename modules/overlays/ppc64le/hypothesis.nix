{ ... }:
final: prev: {
  # No such file or directory: '/build/source/hypothesis-python/.hypothesis/unicode_data/14.0.0/charmap.json.gz'
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pfinal: pprev: {
      hypothesis = pprev.hypothesis.overridePythonAttrs (o: {
        disabledTests = [
          "test_error_writing_charmap_file_is_suppressed"
        ];
      });
    })
  ];
}
