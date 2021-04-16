final: prev: {
  dpt-rp1-py = final.callPackage ./tools/misc/dpt-rp1-py {};
  fast-p = final.callPackage ./tools/text/fast-p {};
  libspnav = final.callPackage ./development/libraries/libspnav {};
  obs-cli = final.callPackage ./tools/misc/obs-cli {};
  obs-websocket = final.libsForQt514.callPackage ./applications/video/obs-studio/obs-websocket.nix {};
  openfec = final.callPackage ./development/libraries/openfec {};
  pragmatapro = final.callPackage ./data/fonts/pragmatapro {};
  purple-plugins-prpl = final.callPackage ./applications/networking/instant-messengers/pidgin-plugins/purple-plugins-prpl {};
  qrcp = final.callPackage ./tools/misc/qrcp {};
  spacenavd = final.callPackage ./misc/spacenavd {};
  udp2raw = final.callPackage ./applications/networking/udp2raw {};
  # uuu = final.callPackage ./tools/misc/uuu {};

  interception-tools-plugins = prev.interception-tools-plugins // {
    dual-function-keys = final.callPackage ./tools/inputmethods/interception-tools/dual-function-keys.nix {};
  };
} // prev.lib.optionalAttrs (with prev.stdenv.targetPlatform; isx86_64 && isLinux)
  {
    roc-toolkit = final.callPackage ./applications/audio/misc/roc-toolkit {};
    uhk-agent = final.callPackage ./misc/uhk-agent {};
  }
  // prev.lib.optionalAttrs prev.stdenv.targetPlatform.isLinux
  {
    linuxPackagesFor = kernel: (prev.linuxPackagesFor kernel).extend (kfinal: kprev: {
      akvcam = kfinal.callPackage ./os-specific/linux/akvcam {};
    });
  }
