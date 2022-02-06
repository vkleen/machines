{ lib, stdenv, fetchurl, makeWrapper, pkg-config, kronosnet, nss, nspr, libqb, autoreconfHook
, dbus, rdma-core, libstatgrab, net-snmp
, enableDbus ? false
, enableInfiniBandRdma ? false
, enableMonitoring ? false
, enableSnmp ? false
, corosync-src
}:

with lib;

stdenv.mkDerivation rec {
  pname = "corosync";
  version = "flake";

  src = corosync-src;

  postPatch = ''
    echo "ref names:tag: v3.1.6" > .gitarchivever
  '';

  nativeBuildInputs = [ makeWrapper autoreconfHook pkg-config ];

  buildInputs = [
    kronosnet nss nspr libqb
  ] ++ optional enableDbus dbus
    ++ optional enableInfiniBandRdma rdma-core
    ++ optional enableMonitoring libstatgrab
    ++ optional enableSnmp net-snmp;

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-logdir=/var/log/corosync"
    "--enable-watchdog"
    "--enable-qdevices"
  ] ++ optional enableDbus "--enable-dbus"
    ++ optional enableInfiniBandRdma "--enable-rdma"
    ++ optional enableMonitoring "--enable-monitoring"
    ++ optional enableSnmp "--enable-snmp";

  installFlags = [
    "sysconfdir=$(out)/etc"
    "localstatedir=$(out)/var"
    "COROSYSCONFDIR=$(out)/etc/corosync"
    "INITDDIR=$(out)/etc/init.d"
    "LOGROTATEDIR=$(out)/etc/logrotate.d"
  ];

  enableParallelBuilding = true;

  preConfigure = optionalString enableInfiniBandRdma ''
    # configure looks for the pkg-config files
    # of librdmacm and libibverbs
    # Howver, rmda-core does not provide a pkg-config file
    # We give the flags manually here:
    export rdmacm_LIBS=-lrdmacm
    export rdmacm_CFLAGS=" "
    export ibverbs_LIBS=-libverbs
    export ibverbs_CFLAGS=" "
  '';

  postInstall = ''
    wrapProgram $out/bin/corosync-blackbox \
      --prefix PATH ":" "$out/sbin:${libqb}/sbin"
  '';

  meta = {
    homepage = "http://corosync.org/";
    description = "A Group Communication System with features for implementing high availability within applications";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ montag451 ryantm ];
  };
}
