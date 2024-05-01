{ ... }:
final: prev: {
  haskell = prev.haskell // {
    compiler = prev.haskell.compiler // {
      ghc865Binary = prev.haskell.compiler.ghc865Binary.overrideAttrs (o: {
        dontStrip = true;
      });
    };

    packageOverrides = hfinal: hprev: {
      servant = final.haskell.lib.doJailbreak hprev.servant;
      servant-server = final.haskell.lib.doJailbreak hprev.servant-server;

      # The fast-logger test suite either hangs or takes foreeeeeever with large numbers of cores
      fast-logger = final.haskell.lib.dontCheck hprev.fast-logger;
    };
  };

  # hs-lua segfaults with ghc92 and later: https://gitlab.haskell.org/ghc/ghc/-/issues/23034
  pandoc = prev.pandoc.override { haskellPackages = final.haskell.packages.ghc90; };

  lua-haskell-shell = final.haskellPackages.shellFor {
    packages = hsPkgs: [ hsPkgs.lua ];
    nativeBuildInputs = [ final.cabal-install final.gdb final.haskellPackages.llvmPackages.llvm ];
  };
}
