final: prev:
{
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++
    (final.lib.optional final.stdenv.hostPlatform.isPower64 (
      self: super: {
        sqlalchemy = super.sqlalchemy.overrideAttrs (_: {
          doCheck = false;
          doInstallCheck = false;
        });
      }
    ));
}
