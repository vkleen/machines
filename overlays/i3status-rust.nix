final: prev: {
  i3status-rust = prev.i3status-rust.overrideAttrs (old: {
    cargoDeps = old.cargoDeps.overrideAttrs (final.lib.const {
      outputHash = "sha256-NJCbgR1ahs2V+J44nB+ZcTTZmSz2/SAzGKR04bJ2jwI=";
    });
  });
}
