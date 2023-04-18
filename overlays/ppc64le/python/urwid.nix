final: prev:
{
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++
    (final.lib.optional final.stdenv.hostPlatform.isPower64 (
      self: super: {
        urwid = super.urwid.overrideAttrs (_: {
          doCheck = false;
        });
      }
    ));
}
