{ ... }:
final: prev: {
  dump_syms = prev.dump_syms.overrideAttrs (o: {
    cargoDeps = final.rustPlatform.importCargoLock {
      lockFile = ./Cargo.lock;
    };
    postPatch = ''
      cp ${./Cargo.lock} Cargo.lock
    '';
    cargoHash = null;
  });
}
