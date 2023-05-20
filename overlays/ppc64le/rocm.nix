final: prev: {
  hip-common = prev.hip-common.overrideAttrs (o: {
    postPatch = (o.postPatch or "") + ''
      sed -i -e 's/clang_rt.builtins-x86_64/clang_rt.builtins-powerpc64le/g' hip-lang-config.cmake.in
      sed -i -e 's/clang_rt.builtins-x86_64/clang_rt.builtins-powerpc64le/g' bin/hipcc.pl
    '';
  });

  hip = prev.hip.overrideAttrs (o: {
    postPatch = (o.postPatch or "") + ''
      sed -i -e 's/clang_rt.builtins-x86_64/clang_rt.builtins-powerpc64le/g' hip-config.cmake.in
    '';
    env.NIX_CFLAGS_COMPILE = "--rtlib=libgcc --unwindlib=libgcc";
  });

  hipcc = prev.hipcc.overrideAttrs (o: {
    postPatch = (o.postPatch or "") + ''
      sed -i -e 's/clang_rt.builtins-x86_64/clang_rt.builtins-powerpc64le/g' src/hipBin_amd.h
    '';
    env.NIX_CFLAGS_COMPILE = "--rtlib=libgcc --unwindlib=libgcc";
  });

  rocm-comgr = prev.rocm-comgr.overrideAttrs (o: {
    cmakeFlags = [ "-DLLVM_TARGETS_TO_BUILD=AMDGPU;PowerPC" ];
    env.NIX_CFLAGS_COMPILE = "--rtlib=libgcc --unwindlib=libgcc";
  });

  rocm-device-libs = prev.rocm-device-libs.overrideAttrs (o: {
    cmakeFlags = [ "-DLLVM_TARGETS_TO_BUILD=AMDGPU;PowerPC" ];
    env.NIX_CFLAGS_COMPILE = "--rtlib=libgcc --unwindlib=libgcc";
  });

  rocm-opencl-runtime = prev.rocm-opencl-runtime.overrideAttrs (o: {
    env.NIX_CFLAGS_COMPILE = "--rtlib=libgcc --unwindlib=libgcc";
  });

  rocm-runtime = prev.rocm-runtime.overrideAttrs (o: {
    env.NIX_CFLAGS_COMPILE = "--rtlib=libgcc --unwindlib=libgcc";
  });

  rocmlir = prev.rocmlir.overrideAttrs (o: {
    cmakeFlags = [
      "-DLLVM_TARGETS_TO_BUILD=AMDGPU;PowerPC"
      "-DLLVM_ENABLE_ZLIB=ON"
      "-DLLVM_ENABLE_TERMINFO=ON"
      "-DROCM_PATH=${final.rocminfo}"
      "-DROCM_TEST_CHIPSET=gfx000"
    ];
    env.NIX_CFLAGS_COMPILE = "--rtlib=libgcc --unwindlib=libgcc";
  });

  rocmlir-rock = null;

  rocminfo = prev.rocminfo.overrideAttrs (o: {
    env.NIX_CFLAGS_COMPILE = "--rtlib=libgcc --unwindlib=libgcc";
  });

  rocm-smi = prev.rocm-smi.overrideAttrs (o: {
    env.NIX_CFLAGS_COMPILE = "--rtlib=libgcc --unwindlib=libgcc";
  });
}
