{stdenv, fetchurl}:

stdenv.mkDerivation {
  name = "gnatboot-6.3.1";

  src = if stdenv.system == "x86_64-linux" then
    ./gnat-6.3.1.tar.gz
    else throw "Platform not supported";

  dontStrip=1;

  installPhase = ''
    mkdir -p $out
    cp -R * $out
    set +e
    for a in $(find $out -type f -executable) ; do
      patchelf --interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
        --set-rpath $(cat $NIX_CC/nix-support/orig-libc)/lib:$(cat $NIX_CC/nix-support/orig-cc)/lib64:$(cat $NIX_CC/nix-support/orig-cc)/lib $a
    done
  '';

  passthru = {
    langC = true; /* TRICK for gcc-wrapper to wrap it */
    langCC = false;
    langFortran = false;
    langAda = true;
  };

  meta = {
    homepage = http://gentoo.org;
    license = stdenv.lib.licenses.gpl3Plus;  # runtime support libraries are typically LGPLv3+
    maintainers = [
      stdenv.lib.maintainers.viric
    ];

    platforms = stdenv.lib.platforms.linux;
  };
}
