{ ... }:
final: prev: {
  gst_all_1 =
    prev.gst_all_1 // {
      gst-plugins-good = prev.gst_all_1.gst-plugins-good.overrideAttrs (o: {
        # aalib fails with unknown reference to "pow"
        mesonFlags = o.mesonFlags ++ [ "-Daalib=disabled" ];
      });
    };
}
