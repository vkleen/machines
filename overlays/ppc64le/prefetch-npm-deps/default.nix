final: prev: {
  prefetch-npm-deps =
    if !final.stdenv.hostPlatform.isPower64 then prev.prefetch-npm-deps
    else
      prev.prefetch-npm-deps.overrideAttrs (o: {
        cargoDeps = final.rustPlatform.importCargoLock {
          lockFile = ./prefetch-npm-deps/Cargo.lock;
          outputHashes = {
            "ring-0.16.20" = "sha256-g18da5FuyRpkToJNrO/TBvoJF5dLi5ZQLmNE46TLo0Y=";
          };
        };
        postPatch = ''
          cp ${./prefetch-npm-deps/Cargo.toml} Cargo.toml
          cp ${./prefetch-npm-deps/Cargo.lock} Cargo.lock
        '';
      });
}
