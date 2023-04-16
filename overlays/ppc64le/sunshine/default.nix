final: prev: {
  sunshine =
    if !final.stdenv.hostPlatform.isPower64
    then prev.sunshine
    else
      prev.sunshine.overrideAttrs (o: {
        buildInputs = builtins.map
          (drv:
            if drv.pname or "" == "libcbs"
            then final.libcbs
            else drv
          )
          o.buildInputs;
      });
  libcbs =
    if final.stdenv.hostPlatform.isPower64
    then
      (final.lib.findFirst (drv: drv.pname == "libcbs") null prev.sunshine.buildInputs).overrideAttrs
        (o: {
          prePatch = ''
            cp ${./include-cbs-config.patch} ffmpeg_patches/cbs/02-include-cbs-config.patch
          '' + o.prePatch;
          patches = o.patches ++ [ ./libcbs-ppc.patch ];
        })
    else null;
}
