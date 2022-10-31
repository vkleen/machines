{config, nixos, pkgs, lib, ...}:

{
  imports = [ ./scripts.nix ];

  home.packages = with pkgs; [
    djvulibre
    evince
    gsettings-desktop-schemas
    i3status
    imagemagick
    imv
    iwgtk
    libnotify
    noti
    pavucontrol
    pinentry-gtk2
    streamlink
    yt-dlp
    yq

    adms
    caneda
    geda
    gerbv
    gtkwave
    #kicad-master
    #kikit
    #librepcb
    #ngspice
    qucs
    eseries

    #pulseview
    dsview
    sigrok-cli

    #cura-x11
    openscad
    #freecad-realthunder-x11
    #solvespace

    dhall

    hledger

    seamly2d

    tmate
  ];
}
