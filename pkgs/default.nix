final: prev: {
  fast-p = final.callPackage ./tools/text/fast-p {};
  libspnav = final.callPackage ./development/libraries/libspnav {};
  pragmatapro = final.callPackage ./data/fonts/pragmatapro {};
  purple-plugins-prpl = final.callPackage ./applications/networking/instant-messengers/pidgin-plugins/purple-plugins-prpl {};
  spacenavd = final.callPackage ./misc/spacenavd {};
  udp2raw = final.callPackage ./applications/networking/udp2raw {};
}
