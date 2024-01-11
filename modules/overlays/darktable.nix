{ ... }:

final: prev: {
  libgphoto2 = prev.libgphoto2.overrideAttrs (o: {
    src = final.fetchFromGitHub {
      owner = "gphoto";
      repo = "libgphoto2";
      rev = "08d03695ead88ceeb0cdf1cc83910bfee80220c8";
      hash = "sha256-WDryi1tfwGGV7MddfoQ1iozPB51IJcVpLED3PauWj5U=";
    };
  });

  darktable = prev.darktable.overrideAttrs (o: {
    src = final.fetchFromGitHub {
      owner = "darktable-org";
      repo = "darktable";
      rev = "8ee9bcfde44de765a261fab8341230acbe8c587c";
      hash = "sha256-Mapl09hjatP4tntpdkkN7M/GoJ/pUrhh8zcCDqIxvq0=";
      fetchSubmodules = true;
    };
  });
}
