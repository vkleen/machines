args@{ pkgs ? import <nixpkgs> {}, ... }:
pkgs.mkShell {
  name = "nixos";
  nativeBuildInputs = with pkgs; [
    rage
  ] ++ pkgs.lib.optional (args ? agenix) args.agenix
    ++ pkgs.lib.optional (args ? home-manager) args.home-manager;
  EDITOR = "kak";
}
