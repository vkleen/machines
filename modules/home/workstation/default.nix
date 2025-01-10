{ pkgs, inputs, ... }:
{
  imports = with inputs.self.nixosModules.home; [
    bat
    dconf
    direnv
    firefox
    fish
    git
    gpg-agent
    helix
    ssh-agent
    starship
    tmux
    xdg
    zathura
    zsh
  ];

  config = {
    home.packages = with pkgs; [
      djvulibre
      evince
      gnupg
      gsettings-desktop-schemas
      i3status
      imagemagick
      imv
      iwgtk
      libnotify
      noti
      pavucontrol
      ripgrep
      sioyek
      streamlink
      tmate
      xh
      yq
      yt-dlp
    ];
  };
}
