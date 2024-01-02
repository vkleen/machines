{ pkgs, lib, inputs, ... }:
{
  imports = with inputs.self.nixosModules.home; [
    dconf
    direnv
    firefox
    git
    gpg-agent
    helix
    redshift
    starship
    tmux
    xdg
    zathura
    zsh
  ];

  config = {
    home.packages = with pkgs; [
      dhall
      djvulibre
      evince
      gnupg
      gsettings-desktop-schemas
      hledger
      i3status
      imagemagick
      imv
      iwgtk
      libnotify
      noti
      pavucontrol
      pinentry-gtk2
      streamlink
      tmate
      yq
      yt-dlp
    ];
  };
}
