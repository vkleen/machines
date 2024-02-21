{ ... }:
final: prev: {
  #TODO: remove once upstream fixed the defaults
  imv = prev.imv.override {
    withBackends = [ "libtiff" "libjpeg" "libpng" "librsvg" "libheif" ];
  };
}
