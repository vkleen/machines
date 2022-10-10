final: prev: {
  bat = prev.bat.overrideAttrs (_: {
    doCheck = false;
    doInstallCheck = false;
  });
}
