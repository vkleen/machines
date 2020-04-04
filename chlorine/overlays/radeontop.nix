self: super: {
  radeontop = super.radeontop.overrideAttrs (o: {
    version = "unstable";
    src = self.fetchFromGitHub {
      sha256 = "0dgn5gq8980n0yj1f1im2bm3v96bgs0g27xak0ciixhf2cwppzar";
      rev = "f2d55d67be896d73df0be99b86af4c29e1ec6bf0";
      repo = "radeontop";
      owner = "clbr";
    };
    makeFlags = o.makeFlags ++ [ "amdgpu=1" ];
  });
}
