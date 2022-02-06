{ lib, stdenv, fetchFromGitHub
, autoreconfHook, pkg-config
, ruby, psmisc, systemd, wget
, python3Packages, python3, corosync, pacemaker
, power-assert, test-unit
, pcs-src }:
with lib; let 
  inherit (python3Packages)
    buildPythonApplication pip setuptools setuptools-scm
    cryptography dateutil lxml pycurl pyparsing tornado
    dacite;
in buildPythonApplication {
  pname = "pcs";
  version = "flake";

  src = pcs-src;

  pythonPath = [
    cryptography dateutil lxml pycurl setuptools
    setuptools-scm pyparsing tornado dacite
  ];

  nativeBuildInputs = [
    autoreconfHook pkg-config pip systemd wget
    ruby power-assert test-unit
  ];

  buildInputs = [ corosync pacemaker wget systemd ruby ];
  format = "other";

  patches = [
    ./patches/pcs-setup-cfg-in.patch
    ./patches/pcs-settings-in.patch
  ];

  postPatch = ''
    find . -name Makefile.am | xargs -xL1 sed -i 's,$(DESTDIR),$(out),g'
  '';

  configureFlags = [
    "--with-distro=debian"
    "--enable-tests-only"
    "--localstatedir=/var"
    "--runstatedir=/run"
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
  ];

  outputs = [ "out" "dev" "doc" "man" ];
}
