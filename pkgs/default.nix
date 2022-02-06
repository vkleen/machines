final: prev: {
  dpt-rp1-py = final.callPackage ./tools/misc/dpt-rp1-py {};
  libspnav = final.callPackage ./development/libraries/libspnav {};
  pragmatapro = final.callPackage ./data/fonts/pragmatapro {};
  purple-plugins-prpl = final.callPackage ./applications/networking/instant-messengers/pidgin-plugins/purple-plugins-prpl {};
  qrcp = final.callPackage ./tools/misc/qrcp {};
  seamly2d = final.libsForQt5.callPackage ./misc/seamly2d {};
  spacenavd = final.callPackage ./misc/spacenavd {};
  uuu = final.callPackage ./tools/misc/uuu {};
  rmfakecloud = final.callPackage ./servers/rmfakecloud {};

  eseries = with final.python3Packages; toPythonApplication eseries;

  power-assert = final.callPackage ./misc/power-assert {};
  test-unit = final.callPackage ./misc/test-unit {};

  python3 = prev.python3.override {
    packageOverrides = pself: _: {
      eseries = pself.callPackage ./tools/misc/eseries {};
      docopt-subcommands = pself.callPackage ./development/python-modules/docopt-subcommands {};
      dacite = pself.callPackage ./development/python-modules/dacite {};
      #paper2remarkable = pself.callPackage ./tools/remarkable/paper2remarkable {};
    };
  };
  python3Packages = final.python3.pkgs;

  pacemaker = final.callPackage ./cluster/pacemaker.nix {};
  pcs = final.callPackage ./cluster/pcs.nix {};
} // prev.lib.optionalAttrs (with prev.stdenv.targetPlatform; isx86_64 && isLinux)
  {
    #paper2remarkable = final.callPackage ./tools/remarkable/paper2remarkable/cli.nix {};
    udp2raw = final.callPackage ./applications/networking/udp2raw {};
    uhk-agent = final.callPackage ./misc/uhk-agent {};
  }
