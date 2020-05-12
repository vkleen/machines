self: super: {
  xapian = super.xapian.overrideAttrs (_: {
    doCheck = false;
  });
}
