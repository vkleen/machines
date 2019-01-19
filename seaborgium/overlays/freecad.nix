self: super: {
  freecad-master = super.freecad.overrideAttrs (orig: rec {
    name = "freecad-${version}";
    version = "0.18_master-20180702";
    src = self.fetchFromGitHub {
      owner = "FreeCAD";
      repo = "FreeCAD";
      rev = "c18785fdb31e378500440de23dcf648a2c79dc5f";
      sha256 = "1qya45f6z940wicb502w0vbfkm0ywskjppmfdd26s3089sr7323r";
    };
    patches = [];
  });
}
