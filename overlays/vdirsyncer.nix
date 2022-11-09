final: prev: {
  aiohttp-oauthlib = final.python3Packages.buildPythonPackage {
    pname = "aiohttp-oauthlib";
    version = "0.1.0";
    src = final.python3.pkgs.fetchPypi {
      pname = "aiohttp-oauthlib";
      version = "0.1.0";
      sha256 = "sha256-iTzRpZ3dDC5OmA46VE+XELfE/7nie0zQOLUf4dcDk7c=";
    };

    propagatedBuildInputs = with final.python3Packages; [ oauthlib aiohttp ];
    nativeBuildInputs = with final.python3Packages; [ setuptools-scm ];
  };

  vdirsyncer = prev.vdirsyncer.overrideAttrs (o: {
    src = final.vdirsyncer-src;
    propagatedBuildInputs = o.propagatedBuildInputs ++ (with final.python3Packages; [
      aiostream aiohttp final.aiohttp-oauthlib
    ]);
    doCheck = false;
    doInstallCheck = false;
    SETUPTOOLS_SCM_PRETEND_VERSION = "flake";
  });
}
