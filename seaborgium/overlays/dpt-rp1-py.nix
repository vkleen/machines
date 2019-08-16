self: super: {
  dpt-rp1-py = super.dpt-rp1-py.overrideAttrs (o: {
    version = "local-2019-02-15";
    src = self.fetchFromGitHub {
      owner = "vkleen";
      repo = "dpt-rp1-py";
      rev = "fc4d0912a818665867a864d44089a027d71ec5b9";
      sha256 = "07381k4a3y67vmnakjldr8dah2m04inyfhf8ydv2l1gb57pzmsvn";
    };
  });
}
