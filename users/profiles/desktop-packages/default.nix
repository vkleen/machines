{config, nixos, pkgs, lib, ...}:

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

  firejail-element = pkgs.writeShellScriptBin "element-desktop" ''
    exec ${nixos.security.wrapperDir}/firejail --whitelist=${config.home.homeDirectory}/.config/Riot ${pkgs.element-desktop}/bin/element-desktop
  '';

  nixos-zoom = pkgs.writeShellScript "nixos-zoom" ''
    ${pkgs.flatpak}/bin/flatpak --user run us.zoom.Zoom "$@"
  '';

  zoomy = pkgs.writeShellScriptBin "zoomy" ''
    ${nixos-zoom} "$(printf '%s\n' "$*" | ${pkgs.gnused}/bin/sed -e 's,^https://[^.]*\.zoom\.us/j/\([0-9]*\)?pwd=\(.*\)$,zoommtg://zoom.us/join?action=join\&confno=\1\&pwd=\2,')"
  '';

  nixos-zoom-desktop-item = pkgs.makeDesktopItem {
    name = "nixos-zoom";
    desktopName = "nix run zoom";
    genericName = "zoom";
    comment = "You know what this is";
    mimeType = "x-scheme-handler/zoommtg";
    exec = "${zoomy}/bin/zoomy %u";
    type = "Application";
    terminal = "false";
    categories = "Utility";
  };
in {
  imports = [ ./scripts.nix ../std-packages ];

  home.packages = with pkgs; [
    calibre
    djvulibre
    dpt-rp1-py
    evince
    firejail-element
    gnome3.gsettings_desktop_schemas
    i3status
    imagemagick
    imv
    noti
    pavucontrol
    pidgin-with-plugins
    pinentry
    renderdoc
    streamlink
    uhubctl
    xorg.xbacklight
    xorg.xinit
    xorg.xkill
    xorg.xmodmap
    xorg.xprop
    xsel
    xterm
    youtube-dl
    yq
    zoomy

    adms
    caneda
    geda
    gerbv
    gtkwave
    kicad-master
    librepcb
    ngspice
    qucs

    pulseview
    sigrok-cli

    cura-x11
    openscad
    freecad-realthunder-x11
    solvespace

    dhall

    hledger
    hledger-interest
    hledger-ui
    # ledger-autosync

    seamly2d

    nixos-zoom-desktop-item
  ];

  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "x-scheme-handler/zoommtg" = "nixos-zoom.desktop";
    };
  };
}
