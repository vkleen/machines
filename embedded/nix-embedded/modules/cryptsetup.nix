{ lib, ... }:
self: super:
{
  packages = pkgs: with pkgs; [
    pkgs.cryptsetup
  ];

  overlays = [
    (self: super: {
      utillinux = lib.statically
        (super.utillinux.override {
          ncurses = null; perl = null; systemd = null;
          minimal = true;
        }).overrideAttrs (o: {
          configureFlags = [
            "--enable-write"
            "--enable-last"
            "--enable-mesg"
            "--disable-use-tty-group"
            "--enable-fs-paths-default=/sbin"
            "--disable-makeinstall-setuid"
            "--disable-makeinstall-chown"
            "--disable-shared"
            "--enable-static"
            "--enable-static-programs=yes"
            "scanf_cv_type_modifier=ms"
          ];
        });

      utillinuxMinimal = self.utillinux;

      libuuid = self.utillinuxMinimal;

      popt = lib.statically super.popt;
      json_c = lib.statically super.json_c;

      cryptsetup = lib.statically (super.cryptsetup.overrideAttrs (o: {
        NIX_LDFLAGS = "";
        configureFlags = [
          "--enable-cryptsetup-reencrypt"
          "--with-crypto_backend=kernel"
          "--disable-shared"
          "--enable-static"
          "--enable-static-cryptsetup"
        ];
      }));
    })
  ];
}
