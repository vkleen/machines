final: prev: {
  gst_all_1 = prev.gst_all_1 // {
    gst-plugins-good = prev.gst_all_1.gst-plugins-good.overrideAttrs (o: {
      # buildInputs = final.lib.filter (drv: drv.pname or "" != "aalib") o.buildInputs;
      # aalib fails with unknown reference to "pow"
      mesonFlags = o.mesonFlags ++ [ "-Daalib=disabled" ];
    });
  };
}
