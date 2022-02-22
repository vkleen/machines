{ lib, stdenv, fetchFromGitHub
, autoreconfHook, pkg-config
, libuuid, glib, libxml2, libxslt, bzip2
, gnutls, libqb, dbus, systemd
, corosync
, python3
, ocfDir ? "/etc/ocf"
, pacemaker-src }:
with lib; stdenv.mkDerivation {
  pname = "pacemaker";
  version = "flake";

  src = pacemaker-src;

  buildInputs = [
    libuuid glib libxml2 libxslt bzip2 gnutls dbus systemd python3
  ];

  propagatedBuildInputs = [ libqb corosync ];
  nativeBuildInputs = [ autoreconfHook pkg-config ];
  enableParallelBuilding = true;

  postPatch = ''
    find . -name Makefile.am | grep -v ./daemons/execd/Makefile.am | xargs -xL1 sed -i 's,$(DESTDIR),$(out),g'
  '';

  preAutoreconf = ''
    ./autogen.sh
  '';

  configureFlags = [
    "--enable-systemd"
    "--with-corosync"
    "--with-gnutls"
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "--with-initdir=${placeholder "out"}/lib/sysvinit"
    "--with-ocfdir=${ocfDir}"
    "--with-ocfrainstalldir=${placeholder "out"}/ocf"
    "--localstatedir=/var"
    "--runstatedir=/run"
  ];

  postFixup = ''
    moveToOutput ocf "$ocf"
  '';

  outputs = [ "out" "dev" "doc" "ocf" ];
}
