{pkgs, config, nixos, ...}:
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
      purple-plugins-prpl
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

  firejail-element = pkgs.writeShellScriptBin "element-desktop" ''
    exec ${nixos.security.wrapperDir}/firejail --whitelist=${config.home.homeDirectory}/.config/Riot ${pkgs.element-desktop}/bin/element-desktop
  '';
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
    borgbackup
    cached-nix-shell
    calc
    calibre
    djvulibre
    dnsutils
    docker-machine
    dos2unix
    dpt-rp1-py
    entr
    et
    evince
    exiftool
    expect
    fd
    file
    firejail-element
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
    imv
    iperf
    iw
    ldns
    libbladeRF
    linode-cli
    llpp
    lrzsz
    lshw
    lsof
    lsscsi
    magic-wormhole
    man-pages
    mercurial
    mkpasswd
    # mosh
    neovim
    nix-index nix-prefetch-scripts
    nix-prefetch-github
    noti
    notmuch
    nox
    pandoc
    # papis
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
    rsync
    sanoid
    skim
    socat
    # socat2pre
    sqlite
    streamlink
    s-tui
    tealdeer
    telnet
    tmux
    tree
    tsocks
    unzip
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
    xterm
    youtube-dl
    yq

    arduino-cli

    imx_usb_loader

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

    cura
    openscad
    # freecad
    solvespace

    dhall

    cycle_powersaving

    hledger
    hledger-interest
    hledger-ui
    # ledger-autosync
  ];
}
