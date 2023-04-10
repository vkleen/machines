final: prev:
let
  callPackage = final.newScope
    {
      haskellLib = prev.haskell.lib;
      overrides = final.haskell.packageOverrides;
    };

  inherit (final.haskell) lib;
in
{
  haskell =
    if !final.stdenv.hostPlatform.isPower64 then prev.haskell else
    prev.haskell // {
      compiler = prev.haskell.compiler // {
        ghc865Binary = prev.haskell.compiler.ghc865Binary.overrideAttrs (o: {
          nativeBuildInputs = (o.nativeBuildInputs or [ ]) ++ [ final.patchelfUnstable ];
        });
        ghc8107Binary = callPackage ./8.10.7-binary.nix {
          llvmPackages = final.llvmPackages_12;
        };
        ghc884 = prev.haskell.compiler.ghc884.override { bootPkgs = final.haskell.packages.ghc8107Binary; };
        ghc8107 = prev.haskell.compiler.ghc8107.override { bootPkgs = final.haskell.packages.ghc8107Binary; };
      };

      packageOverrides = final: prev: {
        hslua-aeson = lib.dontCheck prev.hslua-aeson;
        hslua-classes = lib.dontCheck prev.hslua-classes;
        hslua-core = lib.dontCheck prev.hslua-core;
        hslua = lib.dontCheck prev.hslua;
        hslua-marshalling = lib.dontCheck prev.hslua-marshalling;
        hslua-module-doclayout = lib.dontCheck prev.hslua-module-doclayout;
        hslua-module-path = lib.dontCheck prev.hslua-module-path;
        hslua-module-system = lib.dontCheck prev.hslua-module-system;
        hslua-module-text = lib.dontCheck prev.hslua-module-text;
        hslua-module-version = lib.dontCheck prev.hslua-module-version;
        hslua-objectorientation = lib.dontCheck prev.hslua-objectorientation;
        hslua-packaging = lib.dontCheck prev.hslua-packaging;
        lpeg = lib.dontCheck prev.lpeg;
        lua = lib.dontCheck prev.lua;
        pandoc-lua-marshal = lib.dontCheck prev.pandoc-lua-marshal;
        tasty-lua = lib.dontCheck prev.tasty-lua;
      };
    };
}
