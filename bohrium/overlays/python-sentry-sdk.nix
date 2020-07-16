self: super: rec {
  python3 = super.python3.override (o: {
    packageOverrides = python-self: python-super: (o.packageOverrides or (_:_:{})) python-self python-super // {
      sentry-sdk = python-super.sentry-sdk.overrideAttrs (_: {
        # doInstallCheck = false;
        dontUseSetuptoolsCheck = true;
      });
    };
  });
  python3Packages = super.recurseIntoAttrs python3.pkgs;
}
