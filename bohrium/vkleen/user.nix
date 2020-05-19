args@{ pkgs, lib, ... }:

builtins.map (x: import x args) [
  ./alacritty.nix
  ./bluetooth.nix
  ./browsers.nix
  ./direnv.nix
  ./emacs.nix
  ./env.nix
  ./git.nix
  ./gpg.nix
  ./gtk.nix
  ./kak.nix
  ./kitty.nix
  ./mpv.nix
  ./packages.nix
  ./redshift.nix
  ./rg.nix
  ./scripts.nix
  ./tmux.nix
  ./wayland.nix
  ./zathura.nix
  ./zsh.nix

  # ./qt.nix
  # ./xsession.nix
]
