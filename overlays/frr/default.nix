final: prev: {
  frr = prev.frr.overrideAttrs (o: {
    patches = (o.patches or []) ++ [
      ./patches/disable_sys_admin.patch
    ];
  });
}
