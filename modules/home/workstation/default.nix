{ pkgs, inputs, ... }:
{
  imports = with inputs.self.nixosModules.home; [
    bat
    cursor
    dconf
    direnv
    firefox
    fish
    git
    gpg-agent
    helix
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
      ripgrep
      streamlink
      tmate
      yq
      yt-dlp
    ];
  };
}
