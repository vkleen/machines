{config, nixos, pkgs, lib, ...}:
{
  home.packages = with pkgs; [
    a2ps
    aspell
    aspellDicts.de
    aspellDicts.en
    awscli
    batctl
    bc
    borgbackup
    dnsutils
    dos2unix
    entr
    exiftool
    expect
    fd
    file
    gdrive
    gitRepo
    htop
    iperf
    iw
    ldns
    libbladeRF
    linode-cli
    lrzsz
    lshw
    lsof
    lsscsi
    magic-wormhole
    man-pages
    mbuffer
    mercurial
    nix-index nix-prefetch-scripts
    nix-prefetch-github
    nox
    parallel
    pciutils
    picocom
    poppler_utils
    psmisc
    pv
    pwgen
    qpdf
    qrcp
    radare2
    rsync
    sanoid
    sc-im
    skim
    socat
    sqlite
    s-tui
    inetutils
    tree
    tsocks
    unzip
    usb-modeswitch
    usbutils
    w3m
    wavemon
    yq
  ];
}
