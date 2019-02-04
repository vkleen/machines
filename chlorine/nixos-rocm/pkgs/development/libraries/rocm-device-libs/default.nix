{ stdenv, fetchFromGitHub, cmake
, rocm-llvm, rocm-lld, rocm-clang, rocr }:
let
  enableTargets = [ stdenv.hostPlatform stdenv.targetPlatform "AMDGPU" ];
  inherit (import ../../llvm-backends.nix { inherit (stdenv) lib; })
    llvmBackendList;
in stdenv.mkDerivation rec {
  name = "rocm-device-libs";
  version = "2.0.0";
  src = fetchFromGitHub {
    owner = "RadeonOpenCompute";
    repo = "ROCm-Device-Libs";
    rev = "roc-${version}";
    sha256 = "1wfdx0ikwlsiqkpkvm9rggbjjb064df3hzg2dwr5wd64gy61dy8p";
  };
  nativeBuildInputs = [ cmake ];
  buildInputs = [ rocm-llvm rocm-lld rocm-clang rocr ];
  cmakeBuildType = "Release";
  cmakeFlags = [
    "-DLLVM_TARGETS_TO_BUILD=${llvmBackendList enableTargets}"
    "-DLLVM_DIR=${rocm-llvm}/lib/cmake/llvm"
  ];
  patchPhase = ''
  sed 's|set(CLANG "''${LLVM_TOOLS_BINARY_DIR}/clang''${EXE_SUFFIX}")|set(CLANG "${rocm-clang}/bin/clang")|' -i OCL.cmake
  '';
}
