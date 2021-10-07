final: prev: {
  dpt-rp1-py = final.callPackage ./tools/misc/dpt-rp1-py {};
  fast-p = final.callPackage ./tools/text/fast-p {};
  libspnav = final.callPackage ./development/libraries/libspnav {};
  obs-cli = final.callPackage ./tools/misc/obs-cli {};
  openfec = final.callPackage ./development/libraries/openfec {};
  pragmatapro = final.callPackage ./data/fonts/pragmatapro {};
  purple-plugins-prpl = final.callPackage ./applications/networking/instant-messengers/pidgin-plugins/purple-plugins-prpl {};
  qrcp = final.callPackage ./tools/misc/qrcp {};
  seamly2d = final.libsForQt5.callPackage ./misc/seamly2d {};
  spacenavd = final.callPackage ./misc/spacenavd {};
  uuu = final.callPackage ./tools/misc/uuu {};
  rmfakecloud = final.callPackage ./servers/rmfakecloud {};
} // prev.lib.optionalAttrs (with prev.stdenv.targetPlatform; isx86_64 && isLinux)
  {
    kakoune-cr = final.callPackage ./applications/editors/kakoune.cr {};
    obs-websocket = final.libsForQt514.callPackage ./applications/video/obs-studio/obs-websocket.nix {};
    roc-toolkit = final.callPackage ./applications/audio/misc/roc-toolkit {};
    udp2raw = final.callPackage ./applications/networking/udp2raw {};
    uhk-agent = final.callPackage ./misc/uhk-agent {};
  }
  // prev.lib.optionalAttrs prev.stdenv.targetPlatform.isLinux
  {
    linuxPackagesFor = kernel: (prev.linuxPackagesFor kernel).extend (kfinal: kprev: {
      akvcam = kfinal.callPackage ./os-specific/linux/akvcam {};
    });
  }
