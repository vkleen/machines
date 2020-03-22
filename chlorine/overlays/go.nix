self: super: {
  go_1_12 = super.go_1_12.overrideAttrs (_: {
    doCheck = false;
  });
  go_1_13 = super.go_1_13.overrideAttrs (_: {
    doCheck = false;
  });
}
