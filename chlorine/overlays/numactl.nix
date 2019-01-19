self: super: {
  numactl = super.numactl.overrideAttrs (o: {
    meta = o.meta // {
      platforms = [ "i686-linux" "x86_64-linux" "aarch64-linux" "powerpc64le-linux" ];
    };
  });
}
