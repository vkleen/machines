{ stdenv, fetchFromGitHub, kernel, kmod }:

stdenv.mkDerivation rec {
  name = "akvcam-${version}-${kernel.version}";
  version = "4f6548e080419b5b4aa85fd2ba58f132ead0c4db";

  src = fetchFromGitHub {
    owner = "webcamoid";
    repo = "akvcam";
    rev = "${version}";
    hash = "sha256-tVJ5Q9Vv5rpQ7fZR6FaljvTUdd4/4Xghj91RH7jKHrE=";
  };

  postUnpack = ''
    export sourceRoot="$sourceRoot/src"
  '';

  hardeningDisable = [ "format" "pic" ];

  preBuild = ''
    substituteInPlace Makefile --replace "modules_install" "INSTALL_MOD_PATH=$out modules_install"
    sed -i '/depmod/d' Makefile
    export PATH=${kmod}/sbin:$PATH
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;
  buildInputs = [ kmod ];

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];
}

