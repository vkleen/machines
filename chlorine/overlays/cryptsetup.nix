self: super: {
  cryptsetup = self.cryptsetup23;
  cryptsetup23 = super.cryptsetup.overrideAttrs (o: rec {
    name = "cryptsetup-2.3.1";
    src = self.fetchurl {
      url = "https://www.kernel.org/pub/linux/utils/cryptsetup/v2.3/${name}.tar.xz";
      hash = "sha256-kquk1Vmiz3BD+u2S4PIsWt3qNr1j+MA5ulqPOhWf59I=";
    };
  });
}
