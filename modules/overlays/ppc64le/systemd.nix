{ ... }:
final: prev: {
  systemd = prev.systemd.overrideAttrs (o: {
    env.NIX_CFLAGS_COMPILE = "${o.env.NIX_CFLAGS_COMPILE} -Wno-error=format-overflow";
  });
}
