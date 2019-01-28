args@{ pkgs, lib, ... }:

builtins.map (x: import x args) [
  ./autorandr.nix
  ./browsers.nix
  ./direnv.nix
  ./dunst.nix
  ./emacs.nix
  ./env.nix
  ./git.nix
  ./gpg.nix
  ./keynav.nix
  ./packages.nix
  ./parcellite.nix
  ./qt.nix
  ./redshift.nix
  ./rg.nix
  ./secrets.nix
  ./xsession.nix
  ./zathura.nix
  ./zsh.nix
]
