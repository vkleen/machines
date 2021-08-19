args@{ pkgs ? import <nixpkgs> {}, ... }:
pkgs.mkShell {
  name = "nixos";
  nativeBuildInputs = with pkgs; [
    rage
  ] ++ pkgs.lib.optional (args ? agenix) args.agenix;
  EDITOR = "kak";
}
