args@{ pkgs, lib, ... }:

builtins.map (x: import x args) [
  ./direnv.nix
  ./env.nix
  ./git.nix
  ./kak.nix
  ./packages.nix
  ./rg.nix
  ./scripts.nix
  ./zsh.nix
]
