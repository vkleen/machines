args@{ pkgs, lib, ... }:

builtins.map (x: import x args) [
  ./direnv.nix
  ./env.nix
  ./git.nix
  ./gpg.nix
  ./packages.nix
  ./rg.nix
  ./zsh.nix
]
