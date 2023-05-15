final: prev: {
  blender = prev.blender.override {
    hipSupport = true;
    llvmPackages = final.llvmPackages_15;
  };
}
