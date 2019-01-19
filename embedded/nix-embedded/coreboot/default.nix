{ stdenv, fetchurl, fetchgit, m4, bison, flex, curl, zlib, getopt, ncurses, writeText, python
, configfile ? null, blobs ? (import ./blobs.nix)
, lib, buildPackages
}:
assert (configfile != null);
let
  wrapCC = cc: (buildPackages.wrapCC cc).overrideAttrs (o: {
    installPhase = o.installPhase + ''
      wrap ${o.targetPrefix}gnatgcc ${./gnatwrapper/cc-wrapper.sh} $ccPath/${o.targetPrefix}gnatgcc
      wrap ${o.targetPrefix}gnatmake ${./gnatwrapper/gnat-wrapper.sh} $ccPath/${o.targetPrefix}gnatmake
      wrap ${o.targetPrefix}gnatbind ${./gnatwrapper/gnat-wrapper.sh} $ccPath/${o.targetPrefix}gnatbind
      wrap ${o.targetPrefix}gnatlink ${./gnatwrapper/gnatlink-wrapper.sh} $ccPath/${o.targetPrefix}gnatlink
    '';
    postFixup = o.postFixup + ''
      basePath=$(dirname `echo ${cc}/lib/gcc/*/*/include`)
      ccCFlags+=" -B$basePath -I$basePath/adainclude"
      gnatCFlags="-aI$basePath/adainclude -aO$basePath/adalib"
      echo "$gnatCFlags" > $out/nix-support/gnat-cflags

      sed -e '/if.*cc-ldflags.*then/i if [ -e '$out'/nix-support/gnat-cflags ]; then\n    NIX_${o.infixSalt}_GNATFLAGS_COMPILE="$(< '$out'/nix-support/gnat-cflags) $NIX_${o.infixSalt}_GNATFLAGS_COMPILE"\nfi\n' \
          -e '/NIX+CXXSTDLIB_LINK/a \    NIX+GNATFLAGS_COMPILE' \
          -i $out/nix-support/add-flags.sh
    '';
  });
  gnatboot = wrapCC (buildPackages.callPackage ./gnatboot {});
  gnat-gcc = gcc: gnat:
    wrapCC ((gcc.cc.override {
      stdenv = buildPackages.overrideCC buildPackages.stdenv gnat;
    }).overrideAttrs (o: {
      patches = o.patches ++ [ ./patches/ada-shared.patch ];
      configureFlags = (lib.composed [ (lib.remove "--enable-lto")
                                       (lib.remove "--enable-languages=c,c++")
                                     ] o.configureFlags)
                       ++ [ "--disable-lto"
                            "--enable-languages=c,ada,c++"
                            "--disable-libada"
                          ];
      depsBuildBuild = [ gnat ];
      hardeningDisable = [ "all" ];
      postBuild = ''
        export LIBRARY_PATH=$LIBRARY_PATH:${buildPackages.stdenvNoCC.lib.getLib gnat.libc}/${gnat.libc.libdir or "/lib/"}
        make -C gcc gnatlib-shared gnatlib
        make -C gcc gnattools
      '';
    }));
  gnat-gcc8 = gnat-gcc buildPackages.gcc8 gnatboot;
  gnat-gcc7 = gnat-gcc buildPackages.gcc7 gnatboot;
  gnatStdenv = buildPackages.overrideCC stdenv gnatboot;

  coreboot-version = "4.8.1-Purism-3";

  common = args:
    gnatStdenv.mkDerivation (rec {
      passthru = { inherit gnat-gcc7 gnat-gcc8 gnatboot; };
      version = coreboot-version;
      name = "coreboot${lib.optionalString (args ? subname) ("-" + args.subname)}-${version}";
      src = fetchgit {
        url = "https://github.com/vkleen/coreboot.git";
        rev = "refs/tags/librem13v3";
        sha256 = "0iyjnglbcqpf3ia50yg8h4fqn0ykx92yfszbmln5q02h90hbzrhh";
        fetchSubmodules = true;
      };

      buildInputs = [
        m4 bison flex curl zlib getopt
      ];

      hardeningDisable = [ "all" ];
    } // args);

  coreboot-crossgcc = common rec {
    subname = "xgcc";

    crossgcc-sources = [
      (fetchurl {
        url = "https://ftpmirror.gnu.org/gmp/gmp-6.1.2.tar.xz";
        sha256 = "04hrwahdxyqdik559604r7wrj9ffklwvipgfxgj4ys4skbl6bdc7";
      })
      (fetchurl {
        url = "https://ftpmirror.gnu.org/mpfr/mpfr-3.1.5.tar.xz";
        sha256 = "1g32l2fg8f62lcyzzh88y3fsh6rk539qc6ahhdgvx7wpnf1dwpq1";
      })
      (fetchurl {
        url = "https://ftpmirror.gnu.org/mpc/mpc-1.0.3.tar.gz";
        sha256 = "1hzci2zrrd7v3g1jk35qindq05hbl0bhjcyyisq9z209xb3fqzb1";
      })
      (fetchurl {
        url = "https://sourceware.org/elfutils/ftp/0.170/elfutils-0.170.tar.bz2";
        sha256 = "0rp0r54z44is49c594qy7hr211nhb00aa5y7z74vsybbaxslg10z";
      })
      (fetchurl {
        url = "https://ftpmirror.gnu.org/binutils/binutils-2.29.1.tar.xz";
        sha256 = "0xxm6sy06s2y3vbvf8dfqgixv9cq7xk1i9ahnr9kx7czjr30l0g7";
      })
      (fetchurl {
        url = "https://ftpmirror.gnu.org/gcc/gcc-6.3.0/gcc-6.3.0.tar.bz2";
        sha256 = "17xjz30jb65hcf714vn9gcxvrrji8j20xm7n33qg1ywhyzryfsph";
      })
      (fetchurl {
        url = "https://acpica.org/sites/acpica/files/acpica-unix2-20161222.tar.gz";
        sha256 = "1ymp2yq121d8kb257wpnqh50nj1and4v8c4s5vpsc0fijgym1ims";
      })
    ];

    crossgcc-sources-copy = map
      (f: "cp ${f} util/crossgcc/tarballs/${f.name}\n")
      crossgcc-sources;

    postPatch = ''
      mkdir util/crossgcc/tarballs
      ${toString crossgcc-sources-copy}
    '';

    configurePhase = "true";

    buildPhase = ''
      patchShebangs .
      make crossgcc-i386
    '';

    installPhase = ''
      mkdir -p $out
      cp -a util/crossgcc/xgcc/* $out/
    '';
  };

  coreboot-rom = common rec {
    subname = "rom";
    patches = [
      # ./patches/0000-measuredboot.patch
      # ./patches/0006-purism-librem_skl-Explicitely-enable-VMX-and-Intel-S.patch
      # ./patches/0015-purism-librem_skl-Fix-Librem-15-v3-devicetree-config.patch
      # ./patches/0030-sandybridge.patch
      # ./patches/0001-intel-fsp-Fix-TPM-initialization-when-vboot-is-disab.patch
      # ./patches/0007-intel-fsp-fsp2_0-Fix-FSP-2.0-headers-to-match-github.patch
      # ./patches/0016-purism-librem13v1-librem13v2-liberm15v3-Fix-EC-LPC-I.patch
      # ./patches/0003-soc-intel-skylake-Enable-VT-d-and-X2APIC.patch
      # ./patches/0009-Add-heads-TPM-measurements-to-Skylake-Kabylake.patch
      # ./patches/0017-ec-purism-Fix-the-CPU-s-PPCM-value-for-Turbo-when-se.patch
      # ./patches/0004-soc-intel-skylake-Generate-ACPI-DMAR-table.patch
      # ./patches/0013-intel-cpu-Fix-SpeedStep-enabling.patch
      # ./patches/0018-purism-librem_skl-Add-AC-DC-LoadLine-to-VR-Config.patch
      # ./patches/0005-purism-librem_skl-Enable-TPM-support.patch
      # ./patches/0014-purism-librem_skl-Set-TCC-Activation-at-95C.patch
      # ./patches/0020-kgpe-d16.patch
      ./patches/dont-fetch-memtest86.patch
      ./patches/dont-fetch-seabios.patch
    ];
    memtest86plus = fetchgit {
      url = "https://review.coreboot.org/memtest86plus.git";
      rev = "3754fd440f4009b62244e0f95c56bbb12c2fffcb";
      sha256 = "0vh5lxjakbg01r3i9p457cn3xyznc07anq8acn1jvgvn7fa86q44";
    };

    seabios = fetchgit {
      url = "https://review.coreboot.org/seabios.git";
      rev = "0551a4be2ce599fb60e478b4c15e06ab6587822c";
      sha256 = "1z86x86ixfvdc7lmwm8wklcqy4c2awb51nk00s548yr5gcdmvbk9";
      fetchSubmodules = false;
    };

    postPatch = ''
      cp --no-preserve=mode -r ${memtest86plus} payloads/external/Memtest86Plus/memtest86plus
      cp -r ${seabios} payloads/external/SeaBIOS/seabios
      chmod -R ug+w payloads/external/SeaBIOS/seabios
      ln -s ${coreboot-crossgcc} util/crossgcc/xgcc
    '';

    seabios-bootorder = writeText "bootorder.txt" ''
      /pci@i0cf8/*@17/drive@2/disk@0
      /pci@i0cf8/pci-bridge@1d/*@0
      /pci@i0cf8/*@17/drive@0/disk@0
    '';

    configurePhase = ''
      cp ${configfile} .config
      cp ${blobs.bootsplash} bootsplash.jpg
      substituteInPlace .config \
        --subst-var-by ifd-bin "${blobs.ifd-bin}" \
        --subst-var-by me-bin "${blobs.me-bin}" \
        --subst-var-by fspm-bin "${blobs.fspm-bin}" \
        --subst-var-by fsps-bin "${blobs.fsps-bin}" \
        --subst-var-by ucode "${blobs.ucode}" \
        --subst-var-by gma-vbt "${blobs.gma-vbt}" \
        --subst-var-by vgabios "${blobs.vgabios}" \
        --subst-var-by bootorder "${seabios-bootorder}" \
        --subst-var-by version "${coreboot-version}"

      runHook preConfigure

      make oldconfig DOTCONFIG=$PWD/.config BUILD_TIMELESS=1

      runHook postConfigure
    '';

    buildPhase = ''
      patchShebangs .
      make BUILD_TIMELESS=1
    '';

    installPhase = ''
      cp build/coreboot.rom $out
    '';

    buildInputs = [
      m4 bison flex curl zlib getopt ncurses python
    ];
  };

  coreboot-utils = common rec {
    subname = "utils";

    configurePhase = ''
      true
    '';
    tools = [
      "cbfstool" "ifdtool" "cbmem"
    ];
    buildPhase = ''
      for tool in ${lib.concatStringsSep " " tools}; do
        (
          cd util/$tool
          make
        )
      done
    '';
    installPhase = ''
      mkdir -p $out/bin
      install ${lib.concatMapStringsSep " " (t: "util/${t}/${t}") tools} $out/bin/
    '';
  };
in {
  crossgcc = coreboot-crossgcc;
  rom = coreboot-rom;
  utils = coreboot-utils;
}
