{pkgs, ...}:
let
  purple-events = with pkgs;
    stdenv.mkDerivation {
      name = "purple-events-0.99.1";
      src = fetchurl {
        url = "https://github.com/sardemff7/purple-events/archive/v0.99.1.tar.gz";
        sha256 = "0wiq1zc7qdp9czldapkxy83pgf9asbixq3dd49if4mbijirai3hp";
      };
      preConfigure = ''
        intltoolize --automake --copy --force
      '';
      configureFlags = [
        "--with-purple-plugindir=\${out}/lib/purple-2"
      ];
      buildInputs = [ pidgin intltool autoreconfHook ];
    };
  purple-libnotify-plus = with pkgs;
    stdenv.mkDerivation {
      name = "purple-libnotify-plus-2.99.1";
      src = fetchurl {
        url = "https://github.com/sardemff7/purple-libnotify-plus/archive/v2.99.1.tar.gz";
        sha256 = "12naqyx9im6w22gw6yfwf5wrps2458xqz5nmjrljdlnfb6rkalrh";
      };
      preConfigure = ''
        intltoolize --automake --copy --force
      '';
      configureFlags = [
        "--with-purple-plugindir=\${out}/lib/purple-2"
      ];
      buildInputs = [ pidgin purple-events libnotify intltool autoreconfHook ];
    };
  pidgin-with-plugins = pkgs.pidgin.override {
    plugins = with pkgs; [
      purple-discord purple-hangouts purple-lurch
      purple-matrix purple-plugin-pack telegram-purple
      pidgin-carbons pidgin-xmpp-receipts
      purple-events purple-libnotify-plus
    ];
  };

  cached-nix-shell = import (pkgs.fetchgit {
    url = "https://github.com/xzfc/cached-nix-shell";
    rev = "f34407cec7141971f55d453805935b47066f3eb8";
    sha256 = "0qhwylacrnw2k3g9ndi0s7y6ymvrf74yhmq2jkd8xvqg5vk833h2";
  }) { inherit pkgs; };
in {
  home.packages = with pkgs; [
    (python36.withPackages (ps: with ps; [ py3status dbus-python ]))

    a2ps
    alacritty
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
    borgbackup
    cached-nix-shell
    calc
    djvulibre
    dnsutils
    docker-machine
    dos2unix
    dpt-rp1-py
    entr
    # et
    eternal-terminal
    exiftool
    fd
    feh
    file
    gdrive
    gitAndTools.git-crypt
    gitAndTools.gitRemoteGcrypt
    gitAndTools.hub
    gitRepo
    gnome3.gsettings_desktop_schemas
    gnupg
    htop
    i3status
    imagemagick
    iperf
    iw
    ldns
    libbladeRF
    # libreoffice
    llpp
    lrzsz
    lshw
    lsof
    lsscsi
    magic-wormhole
    man-pages
    mbuffer
    mercurial
    mkpasswd
    # mosh
    mpv
    nix-index nix-prefetch-scripts
    noti
    notmuch
    nox
    # pandoc
    parallel
    pass
    pavucontrol
    pciutils
    picocom
    pidgin-with-plugins
    pinentry
    pmtools
    poppler_utils
    psmisc
    pv
    pwgen
    python3Packages.alot
    qpdf
    radare2
    rfkill
    rsync
    sanoid
    skim
    sqlite
    streamlink
    s-tui
    sxiv
    tealdeer
    telnet
    tmux
    tree
    tsocks
    usb-modeswitch
    usbutils
    w3m
    wavemon
    xorg.xbacklight
    xorg.xinit
    xorg.xkill
    xorg.xmodmap
    xorg.xprop
    xsel
    xsuspender
    xterm
    youtube-dl
    yq

    adms
    caneda
    # geda
    gerbv
    gtkwave
    kicad
    librepcb
    ngspice
    qucs

    pulseview
    sigrok-cli

    imx_usb_loader

    cura
    openscad
    # freecad
    solvespace

    adapta-gtk-theme
    arc-icon-theme
    arc-theme
    gnome3.adwaita-icon-theme
    gtk-engine-murrine
    gtk_engines
    hicolor-icon-theme
    materia-theme
    nixos-icons
    numix-icon-theme
    numix-solarized-gtk-theme
    paper-gtk-theme
    paper-icon-theme

    # dhall
  ];
}
