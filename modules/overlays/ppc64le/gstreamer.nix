{ lib, ... }:
final: prev: {
  gst_all_1 =
    prev.gst_all_1 // {
      gst-plugins-good = prev.gst_all_1.gst-plugins-good.overrideAttrs (o: {
        # aalib fails with unknown reference to "pow"
        mesonFlags = o.mesonFlags ++ [ "-Daalib=disabled" ];
      });
      # openh264 isn't supported on ppc64le
      gst-plugins-bad = (prev.gst_all_1.gst-plugins-bad.override { openh264 = null; }).overrideAttrs (o: {
        mesonFlags = o.mesonFlags ++ [ "-Dopenh264=disabled" ];
      });
    };
}
