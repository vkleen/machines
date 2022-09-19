final: prev: {
  lieer = prev.lieer.overridePythonAttrs (_: {
    src = final.lieer-src;
    propagatedBuildInputs = with final.python3Packages; [
      notmuch2
      oauth2client
      google-api-python-client
      tqdm
      setuptools
    ];
  });
}
