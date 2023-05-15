final: prev: {
  blender =
    if !final.stdenv.hostPlatform.isPower64
    then prev.blender else
      (prev.blender.override {
        llvmPackages = final.llvmPackages_15;
        openimagedenoise = null;
        embree = null;
      }).overrideAttrs (o: {
        cmakeFlags = o.cmakeFlags ++ [ "-DWITH_CYCLES_EMBREE=OFF" ];
      });
}
