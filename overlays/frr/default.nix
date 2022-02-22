final: prev: {
  frr = prev.frr.overrideAttrs (o: {
    version = "flake";
    src = final.frr-src;
    patches = [ ./patches/disable_sys_admin.patch ];
  });
}
