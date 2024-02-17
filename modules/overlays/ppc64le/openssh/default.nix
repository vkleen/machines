{ ... }:
final: prev: {
  openssh = prev.openssh.overrideAttrs (o: {
    patches = o.patches or [ ] ++ [ ./zero-call-used-regs.patch ];
  });
}
