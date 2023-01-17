final: prev: {
  vdirsyncer = prev.vdirsyncer.overrideAttrs (o: {
    src = final.vdirsyncer-src;
    propagatedBuildInputs = o.propagatedBuildInputs ++ (with final.python3Packages; [
      aiostream aiohttp aiohttp-oauthlib
    ]);
    doCheck = false;
    doInstallCheck = false;
    SETUPTOOLS_SCM_PRETEND_VERSION = "flake";
  });
}
