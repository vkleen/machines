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

  cycle_powersaving = pkgs.writeShellScriptBin "cycle-powersaving" ''
    case "$1" in
      on)
        sudo ${pkgs.powerscript}/bin/powerscript.sh offline
        sudo ${pkgs.powerscript}/bin/powerscript.sh online
        ;;
      off)
        sudo ${pkgs.powerscript}/bin/powerscript.sh online
        sudo ${pkgs.powerscript}/bin/powerscript.sh offline
        ;;
      *)
        exit 1
        ;;
    esac
  '';

  cached-nix-shell = import (pkgs.fetchgit {
    url = "https://github.com/xzfc/cached-nix-shell";
    rev = "f34407cec7141971f55d453805935b47066f3eb8";
    sha256 = "0qhwylacrnw2k3g9ndi0s7y6ymvrf74yhmq2jkd8xvqg5vk833h2";
  }) { inherit pkgs; };
in {
  home.packages = with pkgs; [
    (python36.withPackages (ps: with ps; [ py3status dbus-python ]))

    # socat2pre
    #papis
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
    cached-nix-shell
    calc
    calibre
    djvulibre
    dnsutils
    docker-machine
    dos2unix
    dpt-rp1-py
    entr
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
    ip2unix
    iperf
    iw
    ldns
    libbladeRF
    libreoffice
    llpp
    lrzsz
    lshw
    lsof
    lsscsi
    magic-wormhole
    man-pages
    mercurial
    mkpasswd
    mosh
    mpv
    neovim
    nix-index nix-prefetch-scripts
    noti
    notmuch
    nox
    p7zip
    pandoc
    parallel
    pass
    pavucontrol
    pciutils
    picocom
    pidgin-with-plugins
    pinentry
    pmtools
    poppler_utils
    proot
    psmisc
    pv
    pwgen
    python3Packages.alot
    qpdf
    qutebrowser
    radare2
    renderdoc
    rfkill
    riot-desktop
    rsync
    socat
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

    kakoune
    kak-lsp

    adms
    caneda
    geda
    gerbv
    gtkwave
    kicad
    librepcb
    ngspice
    qucs

    pulseview
    sigrok-cli

    cura
    openscad
    freecad
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

    dhall

    fast-p.bin

    cycle_powersaving

    hledger
    hledger-interest
    hledger-ui
    # ledger-autosync
  ];
}
