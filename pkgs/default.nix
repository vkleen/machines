final: prev: {
  dpt-rp1-py = final.callPackage ./tools/misc/dpt-rp1-py {};
  fast-p = final.callPackage ./tools/text/fast-p {};
  libspnav = final.callPackage ./development/libraries/libspnav {};
  openfec = final.callPackage ./development/libraries/openfec {};
  pragmatapro = final.callPackage ./data/fonts/pragmatapro {};
  purple-plugins-prpl = final.callPackage ./applications/networking/instant-messengers/pidgin-plugins/purple-plugins-prpl {};
  spacenavd = final.callPackage ./misc/spacenavd {};
  udp2raw = final.callPackage ./applications/networking/udp2raw {};
} // prev.lib.optionalAttrs (with prev.stdenv.targetPlatform; isx86_64 && isLinux)
  {
    roc-toolkit = final.callPackage ./applications/audio/misc/roc-toolkit {};
  }
  // prev.lib.optionalAttrs prev.stdenv.targetPlatform.isLinux
  {
    linuxPackagesFor = kernel: (prev.linuxPackagesFor kernel).extend (kfinal: kprev: {
      akvcam = kfinal.callPackage ./os-specific/linux/akvcam {};
    });
  }
