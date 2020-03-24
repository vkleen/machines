{pkgs, ...}:
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
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    autossh
    awscli
    batctl
    bc
    blackbox
    cached-nix-shell
    calc
    djvulibre
    dnsutils
    dos2unix
    entr
    exiftool
    fd
    file
    gdrive
    gitAndTools.git-crypt
    gitAndTools.gitRemoteGcrypt
    gitAndTools.hub
    gitRepo
    gnupg
    htop
    imagemagick
    iperf
    ldns
    libbladeRF
    lrzsz
    lshw
    lsof
    lsscsi
    magic-wormhole
    man-pages
    mercurial
    mkpasswd
    mosh
    nix-index nix-prefetch-scripts
    nox
    p7zip
    #pandoc
    #papis
    parallel
    pciutils
    picocom
    pmtools
    psmisc
    pv
    pwgen
    qpdf
    radare2
    rsync
    socat
    #socat2pre
    sqlite
    s-tui
    tealdeer
    telnet
    tmux
    tree
    tsocks
    usb-modeswitch
    usbutils
    xterm
    youtube-dl
    yq

    sigrok-cli

    #dhall

    # hledger
    # hledger-interest
    # hledger-ui
    # ledger-autosync
  ];
}
