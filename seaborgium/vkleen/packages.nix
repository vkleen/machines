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
in {
  home.packages = with pkgs; [
    (python36.withPackages (ps: with ps; [ py3status dbus-python ]))
    a2ps
    alacritty
    autossh
    bc
    blackbox
    calc
    calibre
    djvulibre
    dnsutils
    docker-machine
    dos2unix
    entr
    feh
    file
    gajim
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
    libbladeRF
    lrzsz
    lshw
    lsof
    lsscsi
    man-pages
    mercurial
    mkpasswd
    mosh
    mpv
    neovim
    nix-index nix-prefetch-scripts
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
    python3Packages.alot
    qutebrowser
    rfkill
    rsync
    socat2pre
    sqlite
    sxiv
    telnet
    tmux
    tree
    tsocks
    usb-modeswitch
    usbutils
    w3m
    xorg.xbacklight
    xorg.xinit
    xorg.xmodmap
    xorg.xprop
    xsel
    xsuspender
    xterm
    youtube-dl

    adms
    caneda
    geda
    gerbv
    gtkwave
    kicad-unstable
    librepcb
    ngspice
    qucs

    pulseview
    sigrok-cli

    # freecad-master
    # solvespace

    adapta-gtk-theme materia-theme
    paper-gtk-theme
    numix-icon-theme numix-solarized-gtk-theme
    paper-icon-theme
    hicolor-icon-theme
    gnome3.adwaita-icon-theme
    nixos-icons
    arc-theme
    arc-icon-theme
    gtk-engine-murrine
    gtk_engines

    dhall

    fast-p.bin

    cycle_powersaving
  ];
}
