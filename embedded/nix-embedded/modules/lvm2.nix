{ lib, ... }:
self: super:
{
  packages = pkgs: with pkgs; [
    pkgs.cryptsetup
  ];

  overlays = [
    (self: super: {
      lvm2 = (super.lvm2.overrideAttrs (o: {
        configureFlags = [
          "--enable-devmapper"
          "--disable-selinux"
          "--disable-udev-systemd-background-jobs"
          "--disable-realtime"
          "--disable-dmeventd"
          "--disable-lvmetad"
          "--disable-lvmpolld"
          "--disable-use-lvmlockd"
          "--disable-use-lvmetad"
          "--disable-use-lvmpolld"
          "--disable-blkid_wiping"
          "--disable-cmirrord"
          "--with-cluster=none"
          "--enable-static_link"
          "ac_cv_func_malloc_0_nonnull=yes"
          "ac_cv_func_realloc_0_nonnull=yes"
        ];
        buildInputs = [ self.libuuid ];
        preConfigure = ''
          sed -i /DEFAULT_SYS_DIR/d Makefile.in
          sed -i /DEFAULT_PROFILE_DIR/d conf/Makefile.in
        '';
        postInstall = ''
          rm -r "$out"/etc "$out"/share
          for i in lvm dmsetup; do
            mv "$out"/sbin/$i.static "$out"/sbin/$i
          done
          ln -s -f dmsetup "$out"/sbin/dmstats
          for i in blkdeactivate fsadm lvmconf lvmdump; do
            rm "$out"/sbin/$i
          done
          rm "$out"/lib/*.so*
        '';
      }));
    })
  ];
}
