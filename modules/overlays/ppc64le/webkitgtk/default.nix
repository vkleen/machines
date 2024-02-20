{ ... }:
final: prev: {
  webkitgtk = prev.webkitgtk.overrideAttrs (o: {
    patches = o.patches or [ ] ++ [ ./llint.patch ];
  });
}
