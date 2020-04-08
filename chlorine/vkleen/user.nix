args@{ pkgs, lib, ... }:

builtins.map (x: import x args) [
  ./browsers.nix
  ./clipster.nix
  ./direnv.nix
  ./dunst.nix
  ./env.nix
  ./git.nix
  ./kak.nix
  ./keynav.nix
  ./packages.nix
  ./qt.nix
  ./redshift.nix
  ./rg.nix
  ./scripts.nix
  ./xsession.nix
  ./zsh.nix
]
