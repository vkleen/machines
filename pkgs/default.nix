final: prev: {
  dpt-rp1-py = final.callPackage ./tools/misc/dpt-rp1-py {};
  pragmatapro = final.callPackage ./data/fonts/pragmatapro {};
  purple-plugins-prpl = final.callPackage ./applications/networking/instant-messengers/pidgin-plugins/purple-plugins-prpl {};
  qrcp = final.callPackage ./tools/misc/qrcp {};
  seamly2d = final.libsForQt5.callPackage ./misc/seamly2d {};
  uuu = final.callPackage ./tools/misc/uuu {};
  rmfakecloud = final.callPackage ./servers/rmfakecloud {};

  eseries = with final.python3Packages; toPythonApplication eseries;

  python3 = prev.python3.override (old: {
    packageOverrides = final.lib.composeExtensions (old.packageOverrides or (_: _: {})) (pself: _: {
      eseries = pself.callPackage ./tools/misc/eseries {};
      docopt-subcommands = pself.callPackage ./development/python-modules/docopt-subcommands {};
      #paper2remarkable = pself.callPackage ./tools/remarkable/paper2remarkable {};
    });
  });
  python3Packages = final.python3.pkgs;

  bfd = final.callPackage ./tools/networking/bfd {};
  bfdd = final.callPackage ./servers/misc/bfdd {};

  hut = final.callPackage ./tools/misc/hut {};
} // prev.lib.optionalAttrs (with prev.stdenv.targetPlatform; isx86_64 && isLinux)
  {
    #paper2remarkable = final.callPackage ./tools/remarkable/paper2remarkable/cli.nix {};
    udp2raw = final.callPackage ./applications/networking/udp2raw {};
    uhk-agent = final.callPackage ./misc/uhk-agent {};
  }
