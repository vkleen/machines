final: prev:
{
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++
    (final.lib.optional final.stdenv.hostPlatform.isPower64 (
      self: super: {
        afdko = super.afdko.overrideAttrs (_: {
          disabledTestPaths = [
            "tests/makeotfexe_test.py"
          ];
        });
      }
    ));
}
