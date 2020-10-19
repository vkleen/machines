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
    blackbox
    borgbackup
    cached-nix-shell
    calc
    dnsutils
    docker-machine
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
    notmuch
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
    python3Packages.alot
    qpdf
    radare2
    rsync
    sanoid
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
