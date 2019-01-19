{ lib }:
let
  makeStaticBinaries = stdenv: stdenv //
    { mkDerivation = args: stdenv.mkDerivation (args // {
        NIX_CFLAGS_LINK = "-static";
        configureFlags = (args.configureFlags or []) ++ [
            "--disable-shared" # brrr...
          ];
      });
      isStatic = true;
    };

  makeStaticLibraries = stdenv: stdenv //
    { mkDerivation = args: stdenv.mkDerivation (args // {
        dontDisableStatic = true;
        configureFlags = (args.configureFlags or []) ++ [
          "--enable-static"
          "--disable-shared"
        ];
      });
    };
in rec {
  composed = builtins.foldl' (a: acc: b: a (acc b)) (a: a);
  statically = let stripped = p : if p ? overrideAttrs
                                  then p.overrideAttrs (o: { stripAllList = [ "bin" "sbin" ]; })
                                  else p;
                   statify = p: if (p ? override)
                                then p.override (o: { stdenv = makeStaticBinaries o.stdenv; })
                                else p;
                   statify-lib = p: if (p ? override)
                                    then p.override (o: { stdenv = makeStaticLibraries o.stdenv; })
                                    else p;
               in composed [stripped statify statify-lib];
  allNixFilesIn = with builtins; with lib;
    dir: mapAttrs (name: _: import (dir + "/${name}"))
                  (filterAttrs (name: _: hasSuffix ".nix" name)
                    (readDir dir));

  all-overlays-in = dir: lib.attrValues (allNixFilesIn dir);
}
