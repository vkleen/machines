{config, nixos, pkgs, lib, ...}:
let
  cached-nix-shell = import (pkgs.fetchgit {
    url = "https://github.com/xzfc/cached-nix-shell";
    rev = "f34407cec7141971f55d453805935b47066f3eb8";
    sha256 = "0qhwylacrnw2k3g9ndi0s7y6ymvrf74yhmq2jkd8xvqg5vk833h2";
  }) { inherit pkgs; };
in {
  home.packages = with pkgs; [
    a2ps
    aspell
    aspellDicts.de
    aspellDicts.en
    awscli
    batctl
    bc
    borgbackup
    cached-nix-shell
    dnsutils
    dos2unix
    entr
    exiftool
    expect
    fd
    file
    gdrive
    gitAndTools.git-crypt
    gitAndTools.gitRemoteGcrypt
    gitAndTools.hub
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
    mkpasswd
    nix-index nix-prefetch-scripts
    nix-prefetch-github
    nox
    parallel
    pass
    pciutils
    picocom
    pmtools
    poppler_utils
    psmisc
    pv
    pwgen
    qpdf
    qrcp
    radare2
    rsync
    sanoid
    scim
    skim
    socat
    sqlite
    s-tui
    tealdeer
    telnet
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