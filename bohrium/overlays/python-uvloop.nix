self: super: rec {
  python3 = super.python3.override {
    packageOverrides = python-self: python-super: {
      uvloop = python-super.uvloop.overridePythonAttrs (_: {
        pytestCheckPhase = "true";
      });
    };
  };
  python3Packages = python3.pkgs;
}
