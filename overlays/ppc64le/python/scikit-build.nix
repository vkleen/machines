final: prev:
{
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++
    (final.lib.optional final.stdenv.hostPlatform.isPower64 (
      self: super: {
        scikit-build = super.scikit-build.overrideAttrs (_: {
          disabledTestPaths = [
            "tests/test_issue668_symbol_visibility.py"
          ];
        });
      }
    ));
}
