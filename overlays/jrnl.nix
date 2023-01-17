final: prev: {
  jrnl = prev.jrnl.overridePythonAttrs (_: {
    src = final.jrnl-src;
  });
}
